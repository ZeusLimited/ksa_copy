# frozen_string_literal: true

class Lot < ApplicationRecord
  include Constants
  include GuidGenerate
  has_paper_trail

  has_many :specifications, -> { order(:num) }, dependent: :destroy, inverse_of: :lot
  has_many :plan_specifications, through: :specifications
  has_many :offers, dependent: :destroy
  has_many :win_offers, -> { wins }, class_name: 'Offer'
  has_many :basic_contracts, through: :offers, source: :contract
  has_many :basic_contracts_termination, through: :basic_contracts, source: :contract_termination
  has_many :frame_lots, class_name: 'Lot', foreign_key: 'frame_id'
  has_many :review_lots, dependent: :destroy
  has_many :winner_protocol_lots, validate: false, dependent: :destroy
  has_one :previous_lot, class_name: 'Lot', foreign_key: 'next_id', dependent: :nullify

  has_and_belongs_to_many :winner_protocols
  has_and_belongs_to_many :users, join_table: 'cart_lots'

  belongs_to :plan_lot
  belongs_to :tender
  belongs_to :rebid_type, class_name: 'Dictionary'
  belongs_to :main_direction, class_name: 'Dictionary'
  belongs_to :status, class_name: 'Dictionary'
  belongs_to :subject_type, class_name: 'Dictionary'
  belongs_to :review_protocol
  belongs_to :winner_protocol
  belongs_to :result_protocol
  belongs_to :frame, class_name: 'Lot'
  belongs_to :privacy, class_name: 'Dictionary'
  ### DEPRECATED:
  # belongs_to :activity, class_name: 'Dictionary'
  # belongs_to :object_stage, class_name: 'Dictionary'
  # belongs_to :buisness_type, class_name: 'Dictionary'
  belongs_to :root_customer, class_name: 'Department'
  belongs_to :rebid_protocol
  belongs_to :sme_type, class_name: 'Dictionary', foreign_key: 'sme_type_id'
  belongs_to :order

  accepts_nested_attributes_for :specifications, allow_destroy: true
  accepts_nested_attributes_for :offers

  validates_associated :specifications

  validates :num, :name, :status_id, :subject_type_id, :gkpz_year, presence: true
  validate :valid_public_date
  def valid_public_date
    return unless plan_lot && tender && tender.announce_date && tender_announce_date > plan_lot_announce_date + 1.month
    errors.add(:non_public_reason, :non_public) unless non_public_reason.present?
  end
  validate :valid_sme
  def valid_sme
    return unless gkpz_year >= 2016 && tender_announce_date && plan_lot_last_agreement_for(tender_announce_date)
    return if case plan_lot_last_agreement_for.sme_type_id
              when SmeTypes::SME then sme_type_id == SmeTypes::SME
              else sme_type_id != SmeTypes::SME
              end
    errors.add(:sme_type_id, :non_sme) if sme_type_id == SmeTypes::SME
    errors.add(:sme_type_id, :sme) if sme_type_id != SmeTypes::SME
  end
  validate :announce_date_bigger_then_confirm_date
  def announce_date_bigger_then_confirm_date
    return if tender_announce_date.nil? || plan_lot_last_agreement_for(tender_announce_date)
    errors.add(:base, :announce_date_less_then_confirm_date, num: num)
  end

  after_create :after_create
  before_save :set_root_customer
  before_create :default_values
  after_create :set_order, unless: proc { |l| l.plan_lot.customer_is_organizer? }

  delegate :confirm_date, to: :winner_protocol, prefix: true
  delegate :name, to: :status, prefix: true, allow_nil: true
  delegate :tender_type_name, to: :tender, prefix: false
  delegate :tender_type_id, to: :tender, prefix: false
  delegate :etp_address_id, :unregulated?, to: :tender, prefix: true
  delegate :name, :num, to: :tender, prefix: true, allow_nil: true
  delegate :announce_date, :bid_date, to: :tender, prefix: true, allow_nil: true
  delegate :name, to: :privacy, prefix: true, allow_nil: true
  ### DEPRECATED:
  # delegate :name, to: :activity, prefix: true, allow_nil: true
  # delegate :name, to: :object_stage, prefix: true, allow_nil: true
  # delegate :name, to: :buisness_type, prefix: true, allow_nil: true
  delegate :ownership_shortname, :name, :fullname, to: :root_customer, prefix: true
  delegate :fullname, to: :status, prefix: true
  delegate :stylename_html, to: :status, prefix: true, allow_nil: true
  delegate :gkpz_year, :full_num, :main_direction_id, :lot_name, to: :plan_lot, prefix: true, allow_nil: true
  delegate :main_direction_id, to: :frame, prefix: true
  delegate :num, :confirm_date, to: :rebid_protocol, prefix: true
  delegate :num, :confirm_date, to: :review_protocol, prefix: true
  delegate :control_user_fio_short, :control_created_at, to: :plan_lot, prefix: true, allow_nil: true
  delegate :to_struct, to: :tender, prefix: true, allow_nil: true
  delegate :open_protocol, to: :tender, allow_nil: true
  delegate :unexec_cost, to: :basic_contracts_termination, prefix: true, allow_nil: true
  delegate :name, to: :sme_type, prefix: true, allow_nil: true
  delegate :sme_type_id, :guid, :announce_date, to: :plan_lot, prefix: true, allow_nil: true
  delegate :num, :agreement_date, to: :order, prefix: true, allow_nil: true

  attr_accessor :selected
  money_fields :guarantie_cost
  validates :guarantie_cost, allow_nil: true, numericality: true

  hex_fields :guid, :plan_lot_guid

  scope :last_public, (lambda do |plan_lot_guid|
    joins(:plan_lot)
      .guid_eq("plan_lots.guid", plan_lot_guid)
  end)
  scope :in_control, (lambda do
    joins(:plan_lot)
      .joins('inner join control_plan_lots on control_plan_lots.plan_lot_guid = plan_lots.guid')
      .order('lots.num, lots.sublot_num')
  end)
  scope :in_status, ->(status) { where(status_id: status) }
  scope :not_fail, -> { where.not(status_id: LotStatus::FAIL) }
  scope :rebid_only, (lambda do
    where("id in (select lot_id from review_lots where tender_id = lots.tender_id and rebid_date is not null)")
  end)
  scope :for_rebid_protocol, (lambda do
    rebid_only.in_status(LotStatus::REVIEW_CONFIRM).where(lots: { rebid_protocol_id: nil })
  end)
  scope :for_winner_protocol, (lambda do
    in_status(LotStatus::FOR_WP).where(winner_protocol_id: nil)
  end)
  scope :for_result_protocol, (lambda do
    joins(:tender, :winner_protocol_lots)
      .in_status(LotStatus::WINNER)
      .where(tenders: { tender_type_id: TenderTypes::TENDERS + TenderTypes::AUCTIONS })
      .where(winner_protocol_lots: { solution_type_id: WinnerProtocolSolutionTypes::WINNER })
  end)
  scope :for_contract, (lambda do
    joins(:tender, :winner_protocol_lots)
      .where(["((tender_type_id in (:p1) and solution_type_id = :p2 and status_id in (:p3)) or
              ((tender_type_id not in (:p1) or solution_type_id != :p2) and status_id in (:p4)))",
              p1: TenderTypes::TENDERS + TenderTypes::AUCTIONS,
              p2: WinnerProtocolSolutionTypes::WINNER,
              p3: [LotStatus::RP_SIGN, LotStatus::CONTRACT],
              p4: LotStatus::HELD_WITH_FAIL])
  end)

  # Начальная предельная цена по рамочному конкурсу (для рамок)
  def initial_price
    @initial_price ||= plan_lot.last_agree_version.all_cost
  end

  # Проведено (объявлено) торгов на сумму (для рамок)
  def announced_price
    @announced_price ||= frame_lots.not_fail.reduce(0) do |a, e|
      a + (e.basic_contracts_cost || e.winner_cost || e.specs_cost) - e.basic_contracts_termination.sum(:unexec_cost)
    end
  end

  # Доступный лимит (для рамок)
  def available_limit
    @available_limit ||= initial_price - announced_price
  end

  def winner_cost
    @winner_cost ||= win_offers.map do |o|
      o.offer_specifications.map { |os| os.qty * os.final_cost }.compact.sum
    end.sum
  end

  def basic_contracts_cost
    return if basic_contracts.empty?
    basic_contracts
      .joins(contract_specifications: :specification)
      .sum('specifications.qty * contract_specifications.cost')
  end

  def search_plan_lots_params
    { plan_filter: { years: [plan_lot_gkpz_year], customers: [root_customer_id], num: plan_lot_full_num } }
  end

  def self.change_status(lots, status_current, status_next)
    lots.in_status(status_current).each { |l| l.update_attribute(:status_id, status_next) }
  end

  def assign_from_plan!
    pl = PlanLot.find plan_lot_id
    self.gkpz_year = pl.gkpz_year
    self.name = pl.lot_name
    self.status_id = LotStatus::NEW
    self.subject_type_id = pl.subject_type_id
    self.plan_lot_guid = pl.guid
    specifications.each(&:assign_from_plan!)
    self
  end

  def assign_from_previous!
    lot = Lot.find prev_id
    self.gkpz_year = lot.gkpz_year
    self.name = lot.name
    self.status_id = LotStatus::NEW
    self.subject_type_id = lot.subject_type_id
    self.guid = lot.guid
    self.plan_lot_guid = lot.plan_lot_guid
    specifications.each(&:assign_from_previous!)
    self
  end

  def assign_from_frame!
    lot = Lot.find frame_id
    self.gkpz_year = lot.gkpz_year
    self.status_id = LotStatus::NEW
    self.subject_type_id = lot.subject_type_id
    specifications.each(&:assign_from_frame!)
    self
  end

  def can_copy?
    next_id.nil? &&
      (LotStatus::FATAL.include?(status_id) || (status_contract? && !any_existing_contract?)) &&
      !exist_another_good_lot?
  end

  def contract_set?
    !has_contract.nil?
  end

  def fullname
    "#{nums}: #{name}"
  end

  def name_with_cust
    format("%s %s (%s)", nums, name, root_customer_name)
  end

  def fullnum
    "#{tender.num}.#{num}"
  end

  def nums
    ["Лот №#{num}", sub_num].join('. ')
  end

  def sub_num
    "Подлот №#{sublot_num}." unless sublot_num.nil?
  end

  def fail?
    status_id == LotStatus::FAIL
  end

  def status_contract?
    status_id == LotStatus::CONTRACT
  end

  def specs_cost
    specifications.map(&:total_cost).compact.sum
  end

  def specs_cost_nds
    specifications.sum('qty * cost_nds')
  end

  def customers
    specifications.map(&:customer_name).uniq
  end

  def plan_cost
    plan_lot ? plan_lot.all_cost : 0
  end

  def any_existing_contract?
    basic_contracts.includes(:contract_termination).where(contract_terminations: { id: nil }).exists?
  end

  def winner_single_source?
    return false if winner_protocol_lots.blank?
    winner_protocol_lots.last.solution_type_id == WinnerProtocolSolutionTypes::SINGLE_SOURCE
  end

  def held?
    LotStatus::HELD.include?(status_id)
  end

  private

  def set_order
    self.order = plan_lot.last_valid_order
  end

  def plan_lot_last_agreement_for(date = tender_bid_date)
    @plan_lot_last_agreement_for ||= Hash.new do |h, key|
      h[key] = PlanLot.last_agreement(date).guid_eq(:guid, plan_lot_guid_hex).take
    end
    @plan_lot_last_agreement_for[date]
  end

  def default_values
    self.guid ||= guid_new
  end

  def after_create
    return unless prev_id
    l = Lot.find(prev_id)
    l.next_id = id
    l.save
  end

  def first_spec_root_customer
    spec = specifications.first
    spec && spec.customer_id ? spec.customer.root_id : root_customer_id
  end

  def set_main_direction
    return frame_main_direction_id if frame
    return plan_lot_main_direction_id if TenderTypes::FRAMES.include?(tender_type_id)
    specifications
      .group_by(&:direction_id)
      .each_with_object({}) { |(k, v), h| h[k] = v.sum(&:total_cost) }
      .sort_by { |e| [-e[1], Direction.priorities[e[0]]] }
      .first[0]
  end

  def set_root_customer
    return if specifications.empty?
    self.root_customer_id = first_spec_root_customer if first_spec_root_customer
    self.main_direction_id = set_main_direction
  end

  def exist_another_good_lot?
    if !persisted? || plan_lot_id.nil?
      false
    else
      Lot
        .where.not(id: id)
        .where.not(status_id: Constants::LotStatus::FATAL)
        .joins(:plan_lot).guid_eq('plan_lots.guid', plan_lot.guid_hex)
        .exists?
    end
  end
end

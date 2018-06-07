# frozen_string_literal: true

class Tender < ApplicationRecord
  include Constants
  include GuidGenerate
  include TenderTypeConcern
  has_paper_trail
  paginates_per 15

  CONTRACTOR_ASSOCIATIONS = [
    :department,
    :tender_type,
    :bidders,
    lots: [
      :status, :winner_protocol_lots,
      specifications: :customer,
      plan_lot: [:control, :plan_specifications],
      win_offers: [offer_specifications: :specification, bidder: [contractor: :ownership]]
    ]
  ].freeze

  attr_accessor :what_valid

  if oracle_adapter?
    set_date_columns :announce_date, :guarantie_date_begin, :guarantie_date_end, :order_date
    set_date_columns :offer_reception_start, :offer_reception_stop
  end
  compound_datetime_fields :bid_date, :review_date, :summary_date
  money_fields :prepayment_cost, :prepayment_percent

  belongs_to :department
  belongs_to :commission
  belongs_to :user
  belongs_to :local_time_zone
  belongs_to :tender_type, class_name: 'Dictionary', foreign_key: 'tender_type_id'
  belongs_to :etp_address, class_name: 'Dictionary', foreign_key: 'etp_address_id'
  belongs_to :project_type, class_name: 'Dictionary', foreign_key: "project_text_id"

  has_one :open_protocol, dependent: :destroy, autosave: true

  has_many :lots, -> { order(:num, :sublot_num) }, inverse_of: :tender, dependent: :destroy
  has_many :specifications, through: :lots
  has_many :frames, through: :lots
  has_many :plan_frame_lots, through: :frames, source: :plan_lot
  has_many :plan_lots, -> { order(:num_lot) }, through: :lots
  has_many :plan_lots_files, -> { order(:id) }, through: :plan_lots
  has_many :doc_takers, dependent: :destroy
  has_many :tender_requests, dependent: :destroy
  has_many :bidders, dependent: :destroy, inverse_of: :tender
  has_many :contractors, through: :bidders
  has_many :link_tender_files, -> { order(:id) }, dependent: :destroy
  has_many :tender_draft_criterions, -> { order('num') }, dependent: :destroy
  has_many :tender_eval_criterions, -> { order('position') }, dependent: :destroy
  has_many :tender_content_offers, -> { order('position') }, dependent: :destroy
  has_many :experts, dependent: :destroy
  has_many :rebid_protocols, dependent: :destroy
  has_many :review_protocols, dependent: :destroy
  has_many :winner_protocols, dependent: :destroy, autosave: true, validate: false
  has_many :result_protocols, dependent: :destroy, autosave: true, validate: false
  has_many :basic_contracts, -> { order('lots.num') }, through: :lots

  delegate :fio_full, :email, to: :user, prefix: true, allow_nil: true
  delegate :fullname, :name, to: :tender_type, prefix: true
  delegate :name, to: :department, prefix: true
  delegate :name, to: :commission, prefix: true, allow_nil: true
  delegate :name, to: :etp_address, prefix: true
  delegate :name, to: :local_time_zone, prefix: true, allow_nil: true
  delegate :time_zone, to: :local_time_zone, prefix: false, allow_nil: true
  delegate :open_date, :sign_date, to: :open_protocol, prefix: true, allow_nil: true
  delegate :name_r, to: :commission, prefix: true, allow_nil: true

  accepts_nested_attributes_for :lots, allow_destroy: true
  accepts_nested_attributes_for :bidders, allow_destroy: true
  accepts_nested_attributes_for :tender_draft_criterions, allow_destroy: true
  accepts_nested_attributes_for :tender_eval_criterions, allow_destroy: true
  accepts_nested_attributes_for :tender_content_offers, allow_destroy: true
  accepts_nested_attributes_for :experts, allow_destroy: true
  accepts_nested_attributes_for :link_tender_files, allow_destroy: true

  with_options unless: :noncompetitive? do |t|
    t.validates :announce_place, :bid_place, :review_place, :summary_place, :review_date, :summary_date, presence: true
    t.validates :commission_id, presence: true
  end

  validates :num, :name, :user_id, presence: true
  validates :contract_period_type, inclusion: { in: [true, false] }, unless: :unregulated?
  validates :announce_date, :bid_date, presence: true
  validates :tender_type_id, :etp_address_id, :department_id, presence: true
  validates :commission_id, presence: true, unless: :noncompetitive?
  validates :alternate_offer, numericality: { only_integer: true, allow_nil: true }
  validates :num, :order_num, length: { maximum: 100 }
  validates :announce_place, :bid_place, :confirm_place, :review_place, length: { maximum: 255 }
  validates :summary_place, :project_text, :agency_contract_num, length: { maximum: 255 }
  validates :name, length: { maximum: 500 }
  validates :guarantie_offer, :guarantie_making_money, :contract_guarantie, length: { maximum: 1000 }
  validates :guarantie_recvisits, length: { maximum: 1000 }
  validates :tender_type_explanations, :guarant_criterions, length: { maximum: 4000 }
  validates :alternate_offer_aspects, :maturity, length: { maximum: 4000 }
  validates :prepayment_aspects, :prepayment_period_begin, :prepayment_period_end, length: { maximum: 4000 }
  validates :provide_td, :preferences, length: { maximum: 4000 }
  validates :other_terms, :prepare_offer, :provide_offer, :reason_for_replace, length: { maximum: 4000 }
  validate :validate_dates, :validate_reception_period
  validate :validate_lots, if: proc { |t| t.what_valid == "form" }
  validates :etp_num, length: { maximum: 255 }
  validates :etp_num, length: { maximum: 6 }, if: :b2b_center?
  validate :not_etp, if: :noncompetitive?
  validates :life_offer, numericality: { only_integer: true, allow_nil: true }
  validates :guarantie_offer, :guarant_criterions, :guarantie_recvisits, presence: true, if: :is_guarantie
  validates :guarantie_making_money, presence: true, if: :is_guarantie
  validates :guarantie_offer, :guarant_criterions, :guarantie_recvisits, absence: true, unless: :is_guarantie
  validates :guarantie_making_money, absence: true, unless: :is_guarantie
  validates :official_site_num, length: { maximum: 25 }

  validate :b2b_classifiers_select
  def b2b_classifiers_select
    return if b2b_classifiers.empty?
    errors.add(:base, :b2b_classifiers_must_be_low_level) if B2bClassifier.where(parent_classifier_id: b2b_classifiers).exists?
  end

  validate :validate_uniq_expert
  def validate_uniq_expert
    users = experts.map{ |e| e.user_id if !e._destroy }.compact
    return if users.uniq.count == users.count
    errors.add(:base, :uniq_expert)
  end

  validates_associated :lots

  def reorder_tender_eval_criterions
    tender_eval_criterions.map { |e| [e.num.split('.').map(&:to_i), e] }.sort.each_with_index do |el, i|
      crit = el[1]
      crit.position = i + 1
      crit.save
    end
  end

  def reorder_tender_content_offers
    tender_content_offers.map { |e| [e.num.split('.').map(&:to_i), e] }.sort.each_with_index do |el, i|
      crit = el[1]
      crit.position = i + 1
      crit.save
    end
  end

  def new_bidders?
    contractors.any?(&:orig?)
  end

  def can_create_b2b?
    etp_num.blank? && etp_address_id == EtpAddress::B2B_ENERGO
  end

  def can_fetch_open_protocol_b2b?
    open_protocol&.id.nil? && etp_num.present? && etp_address_id == EtpAddress::B2B_ENERGO
  end

  def etp?
    fail "can't check etp if etp_address_id is nil" if etp_address_id.nil?
    etp_address_id != EtpAddress::NOT_ETP
  end

  def b2b_center?
    etp_address_id == EtpAddress::B2B_ENERGO
  end

  def in_limit?
    return true if unregulated?
    available_limit = department.root.tender_cost_limit.to_f
    if plan_lots.in_control.exists? ||
       available_limit == 0.0 ||
       total_cost > available_limit
      return false
    end
    PlanLot.in_limit?([plan_tenders.to_sql, plan_preselection_tenders.to_sql].join(' UNION ALL '))
  end

  def plan_tenders
    plan_lots.except(:order).plan_tenders
  end

  def plan_preselection_tenders
    PlanLot.where(guid: plan_lots.except(:order).select(:preselection_guid)).last_agreement.plan_tenders
  end

  def total_cost
    lots.map(&:specs_cost).sum
  end

  def type_with_etp
    [tender_type.try(:fullname), etp? ? "(ЭТП)" : "(вне ЭТП)"].join(' ')
  end

  def lots_with_status?(status)
    lots.in_status(status).exists?
  end

  def available_commissions
    @available_commissions ||= Commission.select_for_department(department_id)
  end

  def self.for_contractor(contractor_id, current_user)
    tenders = Tender.includes(*CONTRACTOR_ASSOCIATIONS)
                    .references(*CONTRACTOR_ASSOCIATIONS)
              .joins('inner join offers o on (o.bidder_id = bidders.id and o.lot_id = lots.id and o.version = 0)')
              .where(bidders: { contractor_id: contractor_id })
              .order('tenders.announce_date desc, tenders.num, lots.num')
    if current_user.root_dept_id
      tenders = tenders.where(
        "(specifications.customer_id in (?) or tenders.department_id in (?))",
        Department.subtree_ids_for(current_user.root_dept_id),
        Department.subtree_ids_for(current_user.root_dept_id)
      )
    end
    tenders
  end

  def self.generate_from_frame(params)
    tender = Tender.new(params)
    tender.lots.each(&:assign_from_frame!)
    tender
  end

  def self.generate_from_copy(params)
    tender = Tender.new(params)
    tender.lots.each(&:assign_from_previous!)
    tender
  end

  def self.generate_from_plan(params)
    tender = Tender.new(params)
    tender.lots.each(&:assign_from_plan!)
    tender
  end

  def self.build_from_plan_lots(current_user)
    array_lots = current_user.plan_lots.order('num_tender, num_lot').to_a

    tender = Tender.new(user: current_user)
    first_lot = array_lots.first
    tender.tender_type_id = first_lot.tender_type_id
    tender.etp_address_id = first_lot.etp_address_id
    tender.department_id = first_lot.department.root_id
    tender.announce_place = "Общероссийский официальный сайт по адресу – http://www.zakupki.gov.ru"
    tender.bid_place = "Электронная торговая площадка" if tender.etp?
    tender.num = first_lot.num_tender
    tender.local_time_zone = LocalTimeZone.find_by(time_zone: 'Moscow')

    array_lots.each_with_index { |plan_lot, index| tender.lots << plan_lot.to_lot(index + 1) }
    tender
  end

  def self.build_from_tender_lots(current_user, copy_tender_params)
    ids = copy_tender_params[:lot_ids]
    ids.reject! { |c| c.to_s.empty? } # remove after fix rails and add 'include_hidden: false' to view
    ids = ids.map(&:to_i)

    array_lots = Lot.where(id: ids).to_a

    copy_fields = [
      :num,
      :tender_type_id,
      :etp_address_id,
      :department_id,
      :announce_place,
      :bid_place,
      :name
    ]

    copy_include = { lots: { specifications: :fias_specifications } }

    array_lots.each { |lot| lot.specifications.each { |spec| spec.prev_id = spec.id } }
    tender = array_lots.first.tender.deep_clone only: copy_fields, include: copy_include do |original, kopy|
      kopy.prev_id = original.id if kopy.respond_to?(:prev_id)
      kopy.status_id = LotStatus::NEW if kopy.respond_to?(:status_id)
    end

    tender.lots = tender.lots.to_a.keep_if { |l| ids.include?(l.prev_id) }

    tender.user = current_user
    tender
  end

  def self.build_from_frame(current_user)
    array_lots = current_user.lots

    copy_fields = [
      :etp_address_id,
      :department_id,
      :announce_place,
      :bid_place,
      :name
    ]

    tender = array_lots.first.tender.deep_clone only: copy_fields

    tender.add_lots_from_frames(array_lots)

    tender.lots = tender.lots.to_a.keep_if { |l| current_user.lots.map(&:id).include?(l.frame_id) }

    tender.tender_type_id = TenderTypes::ZZC
    tender.user = current_user
    tender
  end

  def add_lots_from_frames(array_lots, lots_count = 1)
    array_lots.each_with_index do |lot, index|
      lots << lot.deep_clone(include: { specifications: :fias_specifications }) do |original, kopy|
        kopy.num = index + lots_count if kopy.respond_to?(:num) && kopy.class.name == 'Lot'
        kopy.frame_id = original.id if kopy.respond_to?(:frame_id)
        kopy.plan_specification_id = nil if kopy.respond_to?(:plan_specification_id)
        kopy.plan_lot_id = nil if kopy.respond_to?(:plan_lot_id)
        kopy.status_id = LotStatus::NEW if kopy.respond_to?(:status_id)
        kopy.guid = guid_new if kopy.respond_to?(:guid)
        kopy.winner_protocol_id = nil if kopy.respond_to?(:winner_protocol_id)
        kopy.result_protocol_id = nil if kopy.respond_to?(:result_protocol_id)
      end
    end
  end

  def max_lot_status
    lots.map(&:status_id).max
  end

  def public?
    max_lot_status >= LotStatus::PUBLIC
  end

  def plan_sme_types
    lots.map { |l| l.try(:plan_lot).try(:sme_type_id) }.uniq
  end

  def local_bid_date
    return bid_date unless time_zone
    ActiveSupport::TimeZone.new(time_zone).local_to_utc(bid_date).getlocal(Time.zone.utc_offset)
  end

  def request_offers?
    TenderTypes::ZP.include?(tender_type_id)
  end

  def show_official_num?
    false
  end

  def open_protocol_build
    clerk = commission.commission_users.clerks.first if commission
    open_protocol = build_open_protocol
    open_protocol.commission = commission
    open_protocol.clerk_id = clerk.user_id if clerk
    open_protocol.num = "#{num}-В"
    open_protocol.sign_date = bid_date
    open_protocol.open_date = bid_date
    open_protocol.location = bid_place
    open_protocol.resolve =
      "Утвердить протокол заседания #{commission_name_r} по вскрытию конвертов, " \
      "поступивших на #{tender_type.fullname.mb_chars.downcase}"
    open_protocol
  end

  def rebid_protocol_build
    clerk = commission.commission_users.clerks.first if commission
    rebid_protocol = rebid_protocols.build
    rebid_protocol.commission = commission
    rebid_protocol.clerk_id = clerk.user_id if clerk
    rebid_protocol.num = "#{num}-П"
    rebid_protocol.confirm_date = bid_date + 3.days
    rebid_protocol.rebid_date = bid_date
    rebid_protocol.location = bid_place
    rebid_protocol.resolve =
      "Утвердить протокол заседания #{commission_name_r} по вскрытию конвертов, " \
      "поступивших на #{tender_type.fullname.mb_chars.downcase}"
    rebid_protocol
  end

  def to_struct
    to_json(include: { lots: { methods: [:guid_hex, :plan_lot_guid_hex], except: [:guid, :plan_lot_guid] } })
  end

  def terms_violated?
    30.business_day.after(announce_date) < Date.current
  end

  private

  def validate_reception_period
    return unless tender_type_id && bid_date && announce_date
    days_count = TenderDatesForType.find_by(tender_type_id: tender_type_id)&.days.to_i
    return if days_count.zero?

    message, apply_method = if TenderTypes::BUSINESS_DAYS.include?(tender_type_id)
                              %i[reception_business_period business_days]
                            else
                              %i[reception_period days]
                            end

    if sme?
      days_count = 7 if TenderTypes::SME_7_DAYS.include?(tender_type_id) && total_cost >= 30_000_000
      days_count = 5 if tender_type_id == TenderTypes::ZPE
      days_count = 4 if tender_type_id == TenderTypes::ZCE
    end

    return if days_count.public_send(apply_method).after(announce_date.to_date) < bid_date.to_date

    errors.add(:bid_date, message, days_count: days_count)
  end

  def validate_dates
    if announce_date && order_date && announce_date < order_date
      errors.add(:announce_date, :less_than_order_date)
    end

    if announce_date && offer_reception_start && announce_date > offer_reception_start
      errors.add(:announce_date, :greater_than_offer_reception_start)
    end

    if offer_reception_start && offer_reception_stop && offer_reception_start > offer_reception_stop
      errors.add(:offer_reception_start, :greater_than_offer_reception_stop)
    end

    if offer_reception_stop && bid_date && offer_reception_stop > bid_date
      errors.add(:offer_reception_stop, :greater_than_bid_date, bid_date: bid_date.to_date)
    end

    if review_date && summary_date && review_date > summary_date
      errors.add(:review_date, :greater_than_summary_date)
    end

    if guarantie_date_begin && guarantie_date_end && guarantie_date_begin > guarantie_date_end
      errors.add(:guarantie_date_begin, :greater_than_guarantie_date_end)
    end

    errors.add(:bid_date, :greater_than_review_date) if bid_date && review_date && bid_date > review_date
  end

  def validate_lots
    errors.add(:base, :empty_lots) if lots.empty?
    repeated_numbers = lots.group_by(&:nums).select { |_, v| v.size > 1 }.keys
    errors.add(:base, :repeated_numbers, nums: repeated_numbers.join("<br>")) unless repeated_numbers.blank?
    lots.group_by(&:num).values.each do |v|
      errors.add(:base, :sublot_number_0) if v.size > 1 && v.map(&:sublot_num).any? { |e| e.nil? || e < 1 }
      errors.add(:base, :one_sublot, lot_num: v[0].num) if v.size == 1 && !v[0].sublot_num.nil?
    end
  end

  def not_etp
    errors.add(:etp_address_id, :not_etp) unless etp_address_id == EtpAddress::NOT_ETP
  end

  def sme?
    lots.all? { |lot| lot.sme_type_id == SmeTypes::SME }
  end

  def self.filter_by_search_name(search)
    words = search.strip.split(/[\s,]+/)
    filters = []
    words.each do |w|
      filters << sanitize_sql(["(replace(lower(l.name), 'ё', 'е') like replace(lower('%s'), 'ё', 'е'))", "%#{w}%"])
    end
    filters.empty? ? '' : "(" + filters.join(' OR ') + ")"
  end

  def self.filter_by_control_lots
    sanitize_sql <<-SQL
      exists (
        Select 'x'
        From plan_lots sspl
          inner join control_plan_lots scpl on scpl.plan_lot_guid = sspl.guid
        Where sspl.id = l.plan_lot_id
      )
    SQL
  end
end

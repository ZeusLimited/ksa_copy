# frozen_string_literal: true

class Offer < ApplicationRecord
  include Constants
  has_paper_trail version: :paper_trail_version

  before_create :offer_before_create
  after_destroy :offer_after_destroy
  after_update :offer_after_update

  belongs_to :bidder
  belongs_to :lot
  belongs_to :type_offer, class_name: 'Dictionary', foreign_key: 'type_id'
  belongs_to :status, class_name: 'Dictionary', foreign_key: 'status_id'

  has_one :tender, through: :bidder
  has_one :plan_lot, through: :lot
  has_one :contract, -> { where(type: ContractTypes::BASIC) }, dependent: :destroy

  has_many :reduction_contracts,
           -> { where(type: ContractTypes::REDUCTION) },
           class_name: 'Contract',
           dependent: :destroy
  has_many :offer_specifications, dependent: :destroy
  validates_associated :offer_specifications
  has_many :draft_opinions, dependent: :destroy

  delegate :name, :stylename_html, to: :status, prefix: true, allow_nil: true
  delegate :name, :num, :fullname, :name_with_cust, :sme_type_id, to: :lot, prefix: true
  delegate :contractor_name_short, :contractor_legal_addr, :contractor_is_sme, to: :bidder, prefix: true, allow_nil: true
  delegate :num,
           :delivery_date_begin,
           :delivery_date_end,
           :confirm_date,
           :cost,
           :cost_nds,
           :non_delivery_reason,
           to: :contract, prefix: true, allow_nil: true
  delegate :non_sme?, :contractor_guid_hex, to: :bidder, prefix: true
  delegate :unregulated?, to: :tender, prefix: true
  delegate :tender_type_id, :only_source?, to: :tender, allow_nil: true
  delegate :preselection_guid_hex, to: :plan_lot, prefix: true, allow_nil: true

  accepts_nested_attributes_for :offer_specifications
  accepts_nested_attributes_for :draft_opinions
  accepts_nested_attributes_for :contract, allow_destroy: true

  scope :for_lot, ->(lot) { select("offers.*, dictionaries.name as type_name").joins(:type_offer).where(lot_id: lot) }
  scope :by_type, ->(type) { where(type_id: type) }
  scope :rebid, -> { where(rebidded: true) }
  scope :actuals, -> { where(version: 0) }
  scope :receives, -> { where.not(status_id: OfferStatuses::REJECT) }
  scope :wins, -> { where(status_id: OfferStatuses::WIN).actuals }
  scope :order_bidder, (lambda do
    joins(bidder: :contractor)
      .joins("left join ownerships ow on ow.id = contractors.ownership_id")
      .order("ow.shortname, contractors.name")
  end)
  scope :map_by_lot, (lambda do |lot_id|
    select("offers.id, offers.bidder_id, offers.status_id, #{Contractor::NAME} as contractor_name,
      case offers.num when 0 then 'Основная' else 'Альтернативная №'||to_char(offers.num, '999') end as basic_alt,
      sum(specifications.qty*offer_specifications.final_cost) as total_cost")
    .joins(bidder: :contractor, offer_specifications: :specification)
    .joins("left join ownerships ow on ow.id = contractors.ownership_id")
    .where(version: 0)
    .where(lot_id: lot_id)
    .group("offers.id, offers.bidder_id, offers.status_id, #{Contractor::NAME}, offers.num")
    .order("sum(specifications.qty*offer_specifications.final_cost)")
  end)
  scope :for_bid_lot_num, (lambda do |bidder_id, lot_id, num|
    where(bidder_id: bidder_id).where(lot_id: lot_id).where(num: num)
  end)

  validates :num, :status_id, presence: true
  validates :conditions, presence: true, if: proc { |o| o.regulated_win? }
  validates :final_conditions, presence: true, if: proc { |o| o.regulated_win? && o.rebidded }
  validates :num, numericality: { only_integer: true }
  validate :valid_uniq_index, if: proc { |o| o.type_id.nil? }
  validate :valid_one_winner
  validate :valid_sme_winner, unless: :plan_exclusion_order1352?
  validate :valid_zzc_winner
  def valid_zzc_winner
    return unless (win? || receive?) && tender_type_id == TenderTypes::ZZC && plan_lot_preselection_guid_hex
    return if Offer
              .wins
              .joins(bidder: :contractor)
              .where(lot_id: PlanLot.last_public_lot(plan_lot_preselection_guid_hex).id)
              .guid_eq("contractors.guid", bidder_contractor_guid_hex)
              .exists?
    errors.add(:base, :cant_be_an_offer_for_this_lot, name: bidder_contractor_name_short)
  end

  def plan_exclusion_order1352?
    return unless tender && lot
    l = tender.zzc? && lot.frame ? lot.frame : lot
    l.plan_lot && l.plan_lot.exclusion_order1352?
  end

  validate :valid_non_contract_reason
  def valid_non_contract_reason
    return unless tender &&
                  tender.unregulated? &&
                  contract &&
                  tender.announce_date &&
                  contract.confirm_date &&
                  tender.announce_date + 20.days < contract.confirm_date
    errors.add(:non_contract_reason, :non_contract) if non_contract_reason.empty?
  end

  validate :valid_check_msp_offer
  def valid_check_msp_offer
    return unless win? || receive?
    errors.add(:base, :non_sme) if lot_sme_type_id == SmeTypes::SME && !is_bidder_sme_or_nil?
  end

  attr_accessor :plan_lot_id

  def build_contract_with_specs
    c = build_contract
    c.build_contract_specifications
    c.parent_id = find_parent_contract.try(:id)
    c
  end

  def build_reduction_contract_with_specs
    rc = reduction_contracts.build
    rc.parent_id = contract.id
    rc.build_contract_specifications
    rc
  end

  def contract_date_expired?
    return false unless lot && lot.winner_protocol
    contract_date = contract ? contract_confirm_date : Date.current
    lot.winner_protocol_confirm_date + 20 < contract_date
  end

  def win?
    status_id == OfferStatuses::WIN
  end

  def receive?
    status_id == OfferStatuses::RECEIVE
  end

  def num_text
    num == 0 ? "Основная" : "Альтернативная №#{num}"
  end

  def original_cost
    offer_specifications.joins(:specification).sum("qty*offer_specifications.cost")
  end

  def original_cost_nds
    offer_specifications.joins(:specification).sum("qty*offer_specifications.cost_nds")
  end

  def original_nds
    (original_cost_nds / original_cost - 1) * 100
  end

  def final_cost
    offer_specifications.joins(:specification).sum("qty*offer_specifications.final_cost")
  end

  def final_cost_nds
    offer_specifications.joins(:specification).sum("qty*offer_specifications.final_cost_nds")
  end

  def final_nds
    (final_cost_nds / final_cost - 1) * 100
  end

  def clone(type_id, version = 0)
    fail 'Нельзя клонировать оферту, отсутствующую в базе!' unless self.persisted?

    new_offer = deep_clone include: [:offer_specifications], validate: false
    new_offer.type_id = type_id
    new_offer.version = version
    new_offer
  end

  def build_specifications(lot)
    lot.specifications.each { |specification| offer_specifications.build(specification_id: specification.id) }
    self
  end

  def valid_uniq_index
    return if Offer.for_bid_lot_num(bidder_id, lot_id, num).count.zero?
    errors[:base] << "Оферта с таким номером уже существует"
  end

  def valid_one_winner
    return if tender&.frame? || tender&.preselection?
    return unless win?
    winners = Offer.where(lot_id: lot_id).wins
    winners = winners.where.not(id: id) if persisted?

    errors.add(:base, :one_winner) if winners.exists?
  end

  def valid_sme_winner
    return unless regulated_win?
    errors.add(:base, :actual_sme) if bidder_non_sme?
  end

  def next_type
    type_id == OfferTypes::PICKUP ? OfferTypes::OFFER : OfferTypes::REPLACE
  end

  def regulated_win?
    return unless tender
    win? && !tender_unregulated?
  end

  private

  def is_bidder_sme_or_nil?
    bidder_contractor_is_sme || bidder_contractor_is_sme.nil?
  end

  def offer_after_destroy
    Offer.for_bid_lot_num(bidder_id, lot_id, num).where("version > ?", version).update_all('version = version - 1')
  end

  def offer_before_create
    Offer.for_bid_lot_num(bidder_id, lot_id, num).update_all('version = version + 1') if type_id
    self.version ||= 0
    self.type_id ||= OfferTypes::OFFER
  end

  def offer_after_update
    return if self.version == 0

    offer_next = Offer.for_bid_lot_num(bidder_id, lot_id, num)
                 .where(version: self.version - 1).where(type_id: OfferTypes::PICKUP).first
    return unless offer_next
    offer_next.destroy
    offer = clone(OfferTypes::PICKUP, self.version - 1)
    offer.save
  end

  def find_parent_contract
    return unless lot.plan_lot_id
    Contract.joins(lot: :plan_lot)
      .joins("INNER JOIN plan_lots pl_add on plan_lots.guid = pl_add.additional_to")
      .where(['pl_add.id = ?', lot.plan_lot_id])
      .first
  end
end

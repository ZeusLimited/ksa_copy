# frozen_string_literal: true

class Contract < ApplicationRecord
  include Constants
  extend MigrationHelper
  has_paper_trail

  belongs_to :lot
  belongs_to :offer
  belongs_to :parent, class_name: 'Contract'
  belongs_to :type, class_name: 'Dictionary'

  has_one :contract_termination, dependent: :destroy
  has_one :tender, through: :lot

  has_many :contract_specifications, dependent: :destroy
  has_many :sub_contractors, dependent: :destroy
  has_many :children, class_name: 'Contract', foreign_key: "parent_id"
  has_many :contract_files, -> { order(:id) }, dependent: :destroy

  money_fields :total_cost, :total_cost_nds

  delegate :num, to: :lot, prefix: true

  accepts_nested_attributes_for :contract_specifications
  accepts_nested_attributes_for :contract_files, allow_destroy: true

  if oracle_adapter?
    set_date_columns :confirm_date, :delivery_date_begin, :delivery_date_end
  end

  validates :num, :confirm_date, :delivery_date_begin, :delivery_date_end, presence: true
  validates :offer_id, uniqueness: { scope: :type_id, message: :non_uniq },
                       if: proc { |c| c.offer_id && c.basic? }
  validate :end_date_bigger_then_begin_date
  validate :begin_date_bigger_then_confirm_date
  validate :valid_confirm_date, if: :basic?
  validate :valid_non_delivery_reason, if: :basic?

  scope :select_title_fields, (lambda do
    select("contracts.id, contracts.num, contracts.confirm_date, lots.name as lot_name, lots.gkpz_year")
  end)

  scope :basics, -> { where(type_id: Constants::ContractTypes::BASIC) }
  scope :order_by_date, -> { order(:confirm_date) }

  after_create :set_contract_status
  def set_contract_status
    lot.update_attribute(:status_id, Constants::LotStatus::CONTRACT)
  end

  after_destroy :clear_contract_status
  def clear_contract_status
    return unless type_id == ContractTypes::BASIC
    status = lot.result_protocol ? Constants::LotStatus::RP_SIGN : Constants::LotStatus::WINNER
    lot.update_attribute(:status_id, status)
  end

  def title
    "№ #{fullnum} от #{confirm_date}"
  end

  def fullnum
    [num, reg_number].compact.join('/')
  end

  def build_contract_specifications
    offer.offer_specifications.each do |offer_specification|
      contract_specifications.build(specification_id: offer_specification.specification_id,
                                    cost: offer_specification.final_cost,
                                    cost_nds: offer_specification.final_cost_nds)
    end
  end

  def basic?
    type_id == Constants::ContractTypes::BASIC
  end

  def cost
    contract_specifications.joins(:specification).sum('specifications.qty * contract_specifications.cost')
  end

  def cost_nds
    contract_specifications.joins(:specification).sum('specifications.qty * contract_specifications.cost_nds')
  end

  def self.additional_search(term, root_cust_id)
    Contract.joins(:lot)
      .where('lots.root_customer_id = ?', root_cust_id)
      .where(['lower(contracts.num) like lower(:p1) Or lower(lots.name) like lower(:p1)', p1: "%#{term}%"])
  end

  def build_sub_contractor
    sub_contractor = sub_contractors.build
    contract_specifications.joins(:specification).order('specifications.num').each do |contract_spec|
      sub_contractor.sub_contractor_specs.build(
        contract_specification: contract_spec,
        specification: contract_spec.specification
      )
    end
    sub_contractor
  end

  private

  def end_date_bigger_then_begin_date
    return unless delivery_date_begin && delivery_date_end && delivery_date_begin > delivery_date_end
    errors.add(:delivery_date_end, :less_then_delivery_date_begin)
  end

  def begin_date_bigger_then_confirm_date
    return unless tender && tender.tender_type_id != Constants::TenderTypes::ONLY_SOURCE
    return unless delivery_date_begin && confirm_date && confirm_date > delivery_date_begin
    errors.add(:delivery_date_begin, :less_then_contract_date)
  end

  def lot_through_offer
    @lot_through_offer ||= offer.lot if offer
  end

  def valid_confirm_date
    return unless confirm_date &&
                  lot_through_offer &&
                  lot_through_offer.winner_protocol &&
                  lot_through_offer.winner_protocol_confirm_date &&
                  lot_through_offer.winner_protocol_confirm_date > confirm_date
    errors.add(:confirm_date, :less_then_protocol_date)
  end

  def valid_non_delivery_reason
    pl = lot_through_offer.try(:plan_lot)
    return unless delivery_date_begin &&
                  lot_through_offer &&
                  pl &&
                  pl.plan_specifications.exists? &&
                  pl.plan_specifications.minimum('delivery_date_begin') + 1.month < delivery_date_begin
    errors.add(:non_delivery_reason, :non_contract) if non_delivery_reason.blank?
  end
end

# frozen_string_literal: true

class Specification < ApplicationRecord
  include GuidGenerate
  include Constants
  has_paper_trail

  before_create :default_values

  has_many :fias_specifications, dependent: :destroy
  has_many :offer_specifications, dependent: :destroy
  has_many :sub_contractor_specs, dependent: :destroy

  belongs_to :customer, class_name: 'Department', foreign_key: 'customer_id'
  belongs_to :consumer, class_name: 'Department', foreign_key: 'consumer_id'
  belongs_to :lot
  belongs_to :plan_specification
  belongs_to :invest_project
  belongs_to :direction
  belongs_to :financing, class_name: 'Dictionary', foreign_key: 'financing_id'
  belongs_to :product_type, class_name: 'Dictionary', foreign_key: 'product_type_id'
  belongs_to :unit

  has_one :contract_specification, dependent: :destroy, autosave: true
  has_one :okdp, through: :plan_specification
  has_one :okved, through: :plan_specification

  accepts_nested_attributes_for :fias_specifications, allow_destroy: true

  validates :financing_id,
            inclusion: { in: Financing::GROUP1, message: :must_one },
            if: :direction1?
  validates :financing_id,
            inclusion: { in: Financing::GROUP2, message: :must_two },
            if: :direction2?
  validates :direction_id, :qty, presence: true
  validate :cost_nds_not_less_cost
  validate :check_costs
  def check_costs
    if ([TenderTypes::PO] + TenderTypes::FRAMES).include?(lot_tender_type_id)
      errors.add(:cost_money, :eq_non_0) if cost != 0
      errors.add(:cost_nds_money, :eq_non_0) if cost_nds != 0
    else
      errors.add(:cost_money, :eq_0) if cost == 0
      errors.add(:cost_nds_money, :eq_0) if cost_nds == 0
    end
    return unless plan_specification_last_agreement_for && total_cost && total_cost_nds
    errors.add(:cost_money, :less_then_plan) if plan_specification_last_agreement_for.total_cost < total_cost
    errors.add(:cost_nds_money, :less_then_plan) if plan_specification_last_agreement_for.total_cost_nds < total_cost_nds
  end
  validate :check_qty
  def check_qty
    errors.add(:qty, :eq_0) if qty == 0
  end
  validate :okdp_type, :okved_type, unless: proc { |s| s.tender_unregulated? }

  delegate :total_cost, :total_cost_nds, to: :plan_specification, prefix: true
  delegate :name, :shortname, to: :customer, prefix: true
  delegate :name, :shortname, to: :consumer, prefix: true
  delegate :name, to: :direction, prefix: true
  delegate :status_id, to: :lot, prefix: true, allow_nil: true
  delegate :tender_type_id, to: :lot, prefix: true
  delegate :tender_unregulated?, :tender_bid_date, to: :lot, prefix: false
  delegate :tender_announce_date, to: :lot
  delegate :ref_type, to: :okdp, prefix: true
  delegate :ref_type, to: :okved, prefix: true
  delegate :plan_lot_full_num, to: :lot

  hex_fields :guid

  attr_accessor :prev_id
  set_date_columns :delivery_date_begin, :delivery_date_end if oracle_adapter?
  money_fields :cost, :cost_nds

  def assign_from_plan!
    ps = PlanSpecification.find plan_specification_id
    self.consumer_id = ps.consumer_id
    self.customer_id = ps.customer_id
    self.direction_id = ps.direction_id
    self.invest_project_id = ps.invest_project_id
    self.name = ps.name
    self.num = ps.num_spec
    self.product_type_id = ps.product_type_id
    self.unit_id = ps.unit_id
    self.delivery_date_begin = ps.delivery_date_begin
    self.delivery_date_end = ps.delivery_date_end
    self.monitor_service_id = ps.monitor_service_id
    self.plan_specification_guid = ps.guid

    ps.fias_plan_specifications.each do |fps|
      fs = fias_specifications.build
      fs.addr_aoid = fps.addr_aoid
      fs.houseid = fps.houseid
      fs.fias_id = fps.fias_id
    end
  end

  def assign_from_previous!
    spec = Specification.find prev_id
    self.consumer_id = spec.consumer_id
    self.customer_id = spec.customer_id
    self.direction_id = spec.direction_id
    self.invest_project_id = spec.invest_project_id
    self.name = spec.name
    self.num = spec.num
    self.product_type_id = spec.product_type_id
    self.unit_id = spec.unit_id
    self.delivery_date_begin = spec.delivery_date_begin
    self.delivery_date_end = spec.delivery_date_end
    self.guid = spec.guid
    self.monitor_service_id = spec.monitor_service_id
    self.plan_specification_guid = spec.plan_specification_guid

    spec.fias_specifications.each do |fps|
      fs = fias_specifications.build
      fs.addr_aoid = fps.addr_aoid
      fs.houseid = fps.houseid
      fs.fias_id = fps.fias_id
    end
  end

  def assign_from_frame!
    spec = Specification.find frame_id
    self.consumer_id = spec.consumer_id
    self.customer_id = spec.customer_id
    self.direction_id = spec.direction_id
    self.invest_project_id = spec.invest_project_id
    self.num = spec.num
    self.product_type_id = spec.product_type_id
    self.unit_id = spec.unit_id
    self.delivery_date_begin = spec.delivery_date_begin
    self.delivery_date_end = spec.delivery_date_end
    self.monitor_service_id = spec.monitor_service_id
    self.plan_specification_guid = spec.plan_specification_guid

    spec.fias_specifications.each do |fps|
      fs = fias_specifications.build
      fs.addr_aoid = fps.addr_aoid
      fs.houseid = fps.houseid
      fs.fias_id = fps.fias_id
    end
  end

  def okdp_type
    return unless okdp && tender_announce_date
    errors.add(:base, :okdp_type, num: plan_lot_full_num) if (tender_announce_date >= Date.new(2016) && okdp_ref_type != 'OKPD2') ||
                                                             (tender_announce_date < Date.new(2016) && okdp_ref_type != 'OKDP')
  end

  def okved_type
    return unless okved && tender_announce_date
    errors.add(:base, :okved_type, num: plan_lot_full_num) if (tender_announce_date >= Date.new(2016) && okved_ref_type != 'OKVED2') ||
                                                              (tender_announce_date < Date.new(2016) && okved_ref_type != 'OKVED')
  end

  def fullname
    "№#{num}. #{direction_name}. #{name} (#{count_with_unit})"
  end

  def count_with_unit
    "#{qty} × #{unit_name}"
  end

  def direction1?
    @direction1 ||= Direction.routine.pluck(:id).include?(direction_id)
  end

  def direction2?
    @direction2 ||= Direction.invest.pluck(:id).include?(direction_id)
  end

  def plan_specification_last_agreement_for(date = tender_bid_date)
    return unless plan_specification
    PlanSpecification
      .where(plan_lot_id: PlanLot
                            .last_agreement(date)
                            .guid_eq(:guid, lot.plan_lot_guid_hex))
      .guid_eq(:guid, plan_specification.guid_hex)
      .take
  end

  def total_cost
    return unless qty
    qty * cost
  end

  def total_cost_nds
    return unless qty
    qty * cost_nds
  end

  def nds
    return unless cost && cost_nds
    (cost_nds - cost) / cost * 100
  end

  def unit_name
    unit.try(:symbol_name)
  end

  private

  def cost_nds_not_less_cost
    errors.add(:cost_nds_money, :not_less_cost) if cost_nds < cost
  end

  def default_values
    self.guid ||= guid_new
  end
end

# frozen_string_literal: true

class PlanSpecification < ApplicationRecord
  has_paper_trail

  include GuidGenerate, ActionView::Helpers::NumberHelper
  include Constants

  attr_writer :invest_name, :okdp_name, :okved_name

  before_create :generate_guid

  set_date_columns :delivery_date_begin, :delivery_date_end if oracle_adapter?

  delegate :symbol_name, :code, to: :unit, prefix: true, allow_nil: true
  delegate :name, to: :direction, prefix: true
  delegate :name, to: :product_type, prefix: true, allow_nil: true
  delegate :name, to: :financing, prefix: true, allow_nil: true
  delegate :name, :shortname, to: :consumer, prefix: true
  delegate :name, :shortname, to: :customer, prefix: true
  delegate :name, to: :monitor_service, prefix: true, allow_nil: true
  delegate :fullname, :code, to: :okdp, prefix: true, allow_nil: true
  delegate :fullname, :code, to: :okved, prefix: true, allow_nil: true
  delegate :version, :full_num, :status_name, to: :plan_lot, prefix: true
  delegate :user_fio_short, to: :plan_lot, prefix: true
  delegate :unregulated?, to: :plan_lot, prefix: true
  delegate :include_ipivp, to: :plan_lot, prefix: true, allow_nil: true
  delegate :ref_type, to: :okdp, prefix: true
  delegate :ref_type, to: :okved, prefix: true
  delegate :announce_date, to: :plan_lot, prefix: true, allow_nil: true
  delegate :fullname, to: :bp_state, prefix: true, allow_nil: true

  belongs_to :direction
  belongs_to :product_type, class_name: "Dictionary", foreign_key: "product_type_id"
  belongs_to :financing, class_name: "Dictionary", foreign_key: "financing_id"
  belongs_to :consumer, class_name: "Department", foreign_key: "consumer_id"
  belongs_to :customer, class_name: "Department", foreign_key: "customer_id"
  belongs_to :monitor_service, class_name: "Department", foreign_key: "monitor_service_id"
  belongs_to :bp_state, class_name: 'BpState', foreign_key: 'bp_state_id'

  has_and_belongs_to_many :production_units, join_table: 'plan_spec_production_units', class_name: 'Department', validate: false

  belongs_to :okdp
  belongs_to :okved
  belongs_to :unit
  belongs_to :plan_lot
  belongs_to :invest_project

  has_many :fias_plan_specifications, dependent: :destroy
  has_many :plan_spec_amounts, -> { order(:year) }, dependent: :destroy

  has_many :specifications

  accepts_nested_attributes_for :plan_spec_amounts

  accepts_nested_attributes_for :fias_plan_specifications, allow_destroy: true

  scope :history, (lambda do |guid|
    guid_eq("plan_specifications.guid", guid)
      .joins(:plan_lot)
      .includes(:unit, :product_type, :direction, :financing, :customer, :consumer, :monitor_service, :okdp, :okved,
                :plan_spec_amounts, :fias_plan_specifications, plan_lot: [:status, :user])
      .order('plan_lots.version')
  end)

  with_options unless: :plan_lot_include_ipivp do |ps|
    ps.validate :cost_nds_not_less_cost
    def cost_nds_not_less_cost
      errors.add(:cost_nds_money, :not_less_cost) if cost_nds < cost
    end

    ps.validate :check_cost_zero
    def check_cost_zero
      if TenderTypes::PO == plan_lot_tender_type_id
        errors.add(:cost_money, :not_eq_0) unless cost == 0
        errors.add(:cost_nds_money, :not_eq_0) unless cost_nds == 0
      else
        errors.add(:cost_money, :eq_0) if cost == 0
        errors.add(:cost_nds_money, :eq_0) if cost_nds == 0
      end
    end

    ps.validates :okdp_name, :okved_name, :product_type_id, presence: true

    ps.validates :bp_item, presence: true
  end

  validates :tech_curator, presence: true
  validates :curator, presence: true

  validate :validate_delivery_dates
  validates :cost, :cost_nds, :num_spec, :qty, :unit_id, :direction_id, presence: true, numericality: true
  validates :qty, numericality: { less_than_or_equal_to: 2_147_483_647 }
  validates :financing_id, presence: true, numericality: true
  validates :cost_money, :cost_nds_money, presence: true
  validates :requirements, presence: true
  validates :consumer_id, :unit_name, presence: true
  validates :delivery_date_begin, :delivery_date_end, :name, :customer_id, :monitor_service_id, presence: true
  validates :invest_name, presence: true, if: :direction_for_invest?, unless: :plan_lot_include_ipivp
  validates :cost_doc, presence: true, if: :direction_for_invest?, unless: :plan_lot_include_ipivp
  validates :cost_doc, inclusion: { in: proc { Dictionary.cost_docs.pluck(:name) }, allow_blank: true }

  validates :financing_id, exclusion: { in: Financing::INVALID_GROUP, message: "имеет неверное значение" }
  validates :financing_id,
            inclusion: { in: Financing::GROUP1, message: "должен быть из 1-го раздела" },
            if: :direction1?
  validates :financing_id,
            inclusion: { in: Financing::GROUP2, message: "должен быть из 2-го раздела" },
            if: :direction2?

  validates :requirements, :curator, :tech_curator, length: { maximum: 255 }
  validates :name, length: { maximum: 500 }
  validates :bp_item, length: { maximum: 1000 }

  validates_associated :plan_spec_amounts, :fias_plan_specifications

  validate :validate_delivery_dates, :validate_sum_plan_spec_amounts
  validate :okdp_level
  validate :okdp_type, :okved_type

  money_fields :cost, :cost_nds
  hex_fields :guid

  delegate :tender_type_id, to: :plan_lot, prefix: true

  def validate_delivery_dates
    if delivery_date_begin && delivery_date_end && delivery_date_begin > delivery_date_end
      errors.add(:delivery_date_begin, "не может быть позже даты окончания")
    end

    if delivery_date_begin && plan_lot && plan_lot.gkpz_year && delivery_date_begin.year < plan_lot.gkpz_year.to_i
      errors.add(:delivery_date_begin, "не может быть раньше года ГКПЗ (#{plan_lot.gkpz_year})")
    end

    if delivery_date_begin &&
       plan_lot &&
       plan_lot.gkpz_year &&
       delivery_date_begin.year > plan_lot.gkpz_year.to_i &&
       plan_spec_amounts[0] &&
       plan_spec_amounts[0].amount_finance &&
       plan_spec_amounts[0].amount_finance_nds &&
       (plan_spec_amounts[0].amount_finance <= 0 || plan_spec_amounts[0].amount_finance_nds <= 0)
      errors.add(:base, "Закупка относится к ГКПЗ на #{gkpz_year}")
    end
  end

  def validate_sum_plan_spec_amounts
    return if plan_spec_amounts.size == 0
    sum_am = plan_spec_amounts.reduce(0) { |a, e| a + (e.amount_mastery.presence || 0) }
    sum_am_nds = plan_spec_amounts.reduce(0) { |a, e| a + (e.amount_mastery_nds.presence || 0) }
    sum_af = plan_spec_amounts.reduce(0) { |a, e| a + (e.amount_finance.presence || 0) }
    sum_af_nds = plan_spec_amounts.reduce(0) { |a, e| a + (e.amount_finance_nds.presence || 0) }

    if cost.present? && qty.present?
      price = cost * qty
      check_amount_sum(:cost, 'освоению', price, sum_am)
      check_amount_sum(:cost, 'финансированию', price, sum_af)
    end

    if cost_nds.present? && qty.present?
      price = cost_nds * qty
      check_amount_sum(:cost_nds, 'освоению', price, sum_am_nds)
      check_amount_sum(:cost_nds, 'финансированию', price, sum_af_nds)
    end
  end

  def direction_for_invest?
    direction2?
  end

  def direction1?
    @direction1 ||= Direction.routine.pluck(:id).include?(direction_id)
  end

  def direction2?
    @direction2 ||= Direction.invest.pluck(:id).include?(direction_id)
  end

  def session_params
    {
      product_type_id: product_type_id,
      direction_id: direction_id,
      unit_id: unit_id,
      cost_doc: cost_doc,
      financing_id: financing_id,
      consumer_id: consumer_id,
      monitor_service_id: monitor_service_id,
      curator: curator,
      tech_curator: tech_curator,
      delivery_date_begin: delivery_date_begin,
      delivery_date_end: delivery_date_end
    }
  end

  def unit_name
    unit.try(:symbol_name)
  end

  def unit_name=(name)
    u = Unit.where(symbol_name: name).first
    self.unit_id = u ? u.id : nil
  end

  def consumer_name
    consumer.try(:name)
  end

  def consumer_name=(name)
    d = Department.where('ancestry like ? or parent_dept_id is null', "#{customer.root_id}%").where(name: name).first
    self.consumer_id = d ? d.id : nil
  end

  def invest_name
    invest_project.try(:fullname)
  end

  def okdp_name
    okdp.try(:fullname)
  end

  def okved_name
    okved.try(:fullname)
  end

  def total_cost
    return 0 unless qty && cost
    qty * cost
  end

  def total_cost_nds
    return 0 unless qty && cost_nds
    qty * cost_nds
  end

  def to_specification(nested = true)
    spec = Specification.new
    spec.consumer_id = consumer_id
    spec.cost = TenderTypes::FRAMES.include?(plan_lot_tender_type_id) ? 0 : cost
    spec.cost_nds = TenderTypes::FRAMES.include?(plan_lot_tender_type_id) ? 0 : cost_nds
    spec.customer_id = customer_id
    spec.direction_id = direction_id
    spec.financing_id = financing_id
    spec.invest_project_id = invest_project_id
    spec.name = name
    spec.num = num_spec
    spec.plan_specification_id = id
    spec.plan_specification_guid = guid
    spec.product_type_id = product_type_id
    spec.qty = qty
    spec.unit_id = unit_id
    spec.delivery_date_begin = delivery_date_begin
    spec.delivery_date_end = delivery_date_end
    spec.monitor_service_id = monitor_service_id

    return spec unless nested

    fias_plan_specifications.each do |fps|
      fs = spec.fias_specifications.build
      fs.addr_aoid = fps.addr_aoid
      fs.houseid = fps.houseid
    end

    spec
  end

  attr_accessor :nds, :gkpz_year

  private

  def okdp_type
    return unless okdp && plan_lot_announce_date
    errors.add(:okdp_name, :okdp_type_new) if plan_lot_announce_date >= Date.new(2016) && okdp_ref_type != 'OKPD2'
    errors.add(:okdp_name, :okdp_type_old) if plan_lot_announce_date < Date.new(2016) && okdp_ref_type != 'OKDP'
  end

  def okved_type
    return unless okved && plan_lot_announce_date
    errors.add(:okved_name, :okved_type_new) if plan_lot_announce_date >= Date.new(2016) && okved_ref_type != 'OKVED2'
    errors.add(:okved_name, :okved_type_old) if plan_lot_announce_date < Date.new(2016) && okved_ref_type != 'OKVED'
  end

  def okdp_level
    return unless okdp
    errors.add(:okdp_name, :okdp_level) if okdp.depth <= 1
  end

  def generate_guid
    self.guid ||= guid_new
  end

  def check_amount_sum(field, mes, spec, summa)
    message = \
      "должна равняться сумме по «#{mes}» за все года " \
      "(стоимость спецификации: #{number_with_delimiter(spec)}, " \
      "сумма по годам: #{number_with_delimiter(summa)})"
    errors.add(field, message) unless spec == summa
  end
end

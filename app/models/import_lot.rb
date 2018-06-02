# frozen_string_literal: true

class ImportLot < ApplicationRecord
  validates :gkpz_year, :num_tender, :num_lot, :qty, :lot_name, :announce_date,
            :subject_type, :tender_type, :etp_address, :cost, :cost_nds, :direction,
            :bp_item, :requirements, :consumer, :delivery_date_begin,
            :delivery_date_end, :amount_mastery, :amount_mastery_nds,
            presence: true
  validates :gkpz_year, :num_tender, :num_lot, :qty, numericality: { only_integer: true }
  validates :cost, :cost_nds, :amount_mastery, :amount_mastery_nds, :amount_finance, :amount_finance_nds,
            numericality: true, allow_nil: true
  validates :gkpz_year, inclusion: { in: (2008..Time.now.year + 2).to_a.map(&:to_s) }
  validate :valid_uniq_num_lot, :valid_dates, :valid_dicts

  validates :customer, :monitor_service, :financing, :product_type, :tech_curator, :curator, :organizer,
            :amount_finance, :amount_finance_nds, presence: true

  def self.require_fields
    validators.select do |v|
      v.is_a?(ActiveRecord::Validations::PresenceValidator) &&
        (v.options.blank? || v.options[:if] == :ksazd)
    end.map(&:attributes).flatten
  end

  def customer_record
    if customer
      d = Department.where(name: customer).first
      d ? d.root : nil
    else
      nil
    end
  end

  def valid_dicts
    valid_dic :subject_type, Dictionary.subject_types.pluck(:name)
    valid_dic :tender_type, Dictionary.tender_types.pluck(:name)
    valid_dic :etp_address, Dictionary.etp_addresses.pluck(:name)
    valid_dic :direction, Direction.pluck(:name)
    valid_dic :monitor_service, Department.monitor_services.pluck(:name)
    valid_dic :customer, Department.customers.pluck(:name)
    valid_dic :organizer, Department.organizers.pluck(:name)
    valid_dic :financing, Dictionary.financing_sources.pluck(:name)
    valid_dic :product_type, Dictionary.product_types.pluck(:name)
    valid_dic :consumer, Department.consumers.pluck(:name)
  end

  def valid_dates
    date_attributes = [:announce_date, :delivery_date_begin, :delivery_date_end]

    date_attributes.each do |date_attribute|
      errors.add(date_attribute, "неверный формат даты") unless date?(read_attribute(date_attribute))
    end
  end

  def date?(val)
    res = true
    begin
      Date.parse(val)
    rescue
      res = false
    end
    res
  end

  def valid_uniq_num_lot
    return unless num_lot && num_tender && gkpz_year && customer_record

    lots = PlanLot.actuals.where(gkpz_year: gkpz_year).where(num_tender: num_tender).where(num_lot: num_lot)
    lots = lots.where(
      'plan_lots.id in (select ps.plan_lot_id from plan_specifications ps where ps.customer_id in (?))',
      customer_record.subtree.customers.map(&:id)
    )
    errors.add(:num_lot, "у этой закупки уже есть такой лот!") if lots.count > 0
  end

  def create_plan_lot(root_dept_id, current_user)
    return if invalid?

    plan_lot = PlanLot.new
    plan_lot.version = 0
    plan_lot.gkpz_year = gkpz_year.to_i
    plan_lot.num_tender = num_tender.to_i
    plan_lot.num_lot = num_lot.to_i
    plan_lot.lot_name = lot_name
    plan_lot.tender_type_id = Dictionary.tender_types.by_name(tender_type).first.id
    plan_lot.tender_type_explanations = tender_type_explanations
    plan_lot.subject_type_id = Dictionary.subject_types.by_name(subject_type).first.id
    plan_lot.etp_address_id = Dictionary.etp_addresses.by_name(etp_address).first.id
    plan_lot.announce_date = Date.parse(announce_date)
    plan_lot.point_clause = point_clause
    plan_lot.status_id = Constants::PlanLotStatus::IMPORT
    plan_lot.user_id = current_user.id

    plan_specification = plan_lot.plan_specifications.build

    plan_specification.num_spec = 1
    plan_specification.name = lot_name
    plan_specification.qty = qty
    plan_specification.cost = cost
    plan_specification.cost_nds = cost_nds
    plan_specification.cost_doc = cost_doc
    plan_specification.direction_id = Direction.where('lower(name) = lower(?)', direction).first.id
    plan_specification.consumer_id = Department.define_by_name(consumer, root_dept_id).id
    plan_specification.delivery_date_begin = Date.parse(delivery_date_begin)
    plan_specification.delivery_date_end = Date.parse(delivery_date_end)
    plan_specification.requirements = requirements
    plan_specification.note = note

    psa = plan_specification.plan_spec_amounts.build(year: plan_lot.gkpz_year)
    psa.amount_mastery = amount_mastery
    psa.amount_mastery_nds = amount_mastery_nds

    plan_lot.department_id = Department.define_org_by_name(organizer, root_dept_id).id
    plan_lot.explanations_doc = explanations_doc
    plan_lot.root_customer_id = Department.define_by_name(customer, root_dept_id).root_id

    plan_specification.customer_id = Department.define_by_name(customer, root_dept_id).id
    plan_specification.monitor_service_id = Department.monitor_services.by_name(monitor_service).first.id
    plan_specification.curator = curator
    plan_specification.tech_curator = tech_curator
    plan_specification.bp_item = bp_item
    plan_specification.product_type_id = Dictionary.product_types.by_name(product_type).first.id
    plan_specification.financing_id = Dictionary.financing_sources.by_name(financing).first.id

    psa.amount_finance = amount_finance
    psa.amount_finance_nds = amount_finance_nds

    plan_lot.save!(validate: false)
  end

  private

  def valid_dic(field, values)
    return unless read_attribute(field).present?
    return if values.map { |v| v.mb_chars.downcase }.include?(read_attribute(field).mb_chars.downcase)
    errors.add(field, :inclusion)
  end
end

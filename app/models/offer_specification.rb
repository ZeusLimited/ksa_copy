# frozen_string_literal: true

class OfferSpecification < ApplicationRecord
  has_paper_trail

  belongs_to :offer
  belongs_to :specification, autosave: true

  delegate :fullname, :count_with_unit, to: :specification, prefix: true
  delegate :lot_tender_type_id, :qty, to: :specification, prefix: false
  delegate :financing_id, to: :specification, prefix: true, allow_nil: true
  delegate :unit_name, to: :specification, allow_nil: true

  validates :cost, :cost_nds, :final_cost, :final_cost_nds, presence: true
  validate :check_zero_costs
  def check_zero_costs
    return if [Constants::TenderTypes::PO, Constants::TenderTypes::FRAMES].flatten.include?(lot_tender_type_id)
    %i(cost cost_nds final_cost final_cost_nds).each do |field|
      errors.add("#{field}_money".to_sym, :non_zero) if public_send(field) == 0
    end
  end

  money_fields :cost, :cost_nds, :final_cost, :final_cost_nds

  attr_accessor :plan_specification_id, :financing_id

  def final_nds
    return unless final_cost && final_cost_nds
    ((final_cost_nds.to_f / final_cost - 1) * 100).round 2
  end
end

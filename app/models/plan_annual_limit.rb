# frozen_string_literal: true

class PlanAnnualLimit < ApplicationRecord
  has_paper_trail

  belongs_to :plan_lot

  money_fields :cost, :cost_nds

  validates :year, :cost, :cost_nds, presence: true
  validate :check_cost_zero
  def check_cost_zero
    errors.add(:cost_money, :eq_0) if cost == 0
    errors.add(:cost_nds_money, :eq_0) if cost_nds == 0
  end

 validate :cost_nds_not_less_cost
  def cost_nds_not_less_cost
    return unless cost && cost_nds
    errors.add(:cost_nds_money, :not_less_cost) if cost_nds < cost
  end

end

# frozen_string_literal: true

class PlanSpecAmount < ApplicationRecord
  has_paper_trail

  money_fields :amount_mastery, :amount_mastery_nds, :amount_finance, :amount_finance_nds
  validates :amount_mastery, :amount_mastery_nds, :amount_finance, :amount_finance_nds, presence: true

  belongs_to :plan_specification
end

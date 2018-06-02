# frozen_string_literal: true

class ContractSpecification < ApplicationRecord
  has_paper_trail

  attr_accessor :nds

  belongs_to :specification
  belongs_to :contract

  has_many :contract_amounts, -> { order(:year) }, dependent: :destroy
  has_many :sub_contractor_specs, dependent: :destroy

  delegate :num, :qty, :name, :fullname, to: :specification, prefix: true
  delegate :unit_name, to: :specification, prefix: true, allow_nil: true

  accepts_nested_attributes_for :contract_amounts, allow_destroy: true

  money_fields :cost, :cost_nds

  validates :cost, :cost_money, :cost_nds, :cost_nds_money, presence: true
  validate :validate_sum_spec_amounts
  def validate_sum_spec_amounts
    return if contract_amounts.size == 0
    sum_af = contract_amounts.reduce(0) { |a, e| a + specification_qty * (e.amount_finance.presence || 0) }
    sum_af_nds = contract_amounts.reduce(0) { |a, e| a + specification_qty * (e.amount_finance_nds.presence || 0) }

    if cost.present?
      price = cost * specification_qty
      errors.add(:cost_money,
                 :fail,
                 spec: number_with_delimiter(price),
                 summa: number_with_delimiter(sum_af)) unless price == sum_af
    end

    if cost_nds.present?
      price = cost_nds * specification_qty
      errors.add(:cost_nds_money,
                 :fail,
                 spec: number_with_delimiter(price),
                 summa: number_with_delimiter(sum_af_nds)) unless price == sum_af_nds
    end
  end

  def nds
    ((cost_nds / cost - 1) * 100).round(2) if cost && cost_nds
  end
end

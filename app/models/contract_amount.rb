# frozen_string_literal: true

class ContractAmount < ApplicationRecord
  has_paper_trail

  belongs_to :contract_specification

  money_fields :amount_finance, :amount_finance_nds

  validates :amount_finance_money, :amount_finance_nds_money, presence: true
  validates :amount_finance, :amount_finance_nds, presence: true
end

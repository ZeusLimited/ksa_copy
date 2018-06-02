# frozen_string_literal: true

class ContractTermination < ApplicationRecord
  has_paper_trail

  belongs_to :contract
  belongs_to :type, class_name: 'Dictionary', foreign_key: 'type_id'

  delegate :name, to: :type, prefix: true

  money_fields :unexec_cost

  set_date_columns :cancel_date if oracle_adapter?

  validates :unexec_cost_money, :cancel_date, presence: true
end

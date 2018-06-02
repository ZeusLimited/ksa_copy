# frozen_string_literal: true

class SubContractor < ApplicationRecord
  has_paper_trail

  has_many :sub_contractor_specs, dependent: :delete_all
  belongs_to :contract
  belongs_to :contractor

  set_date_columns :confirm_date, :begin_date, :end_date if oracle_adapter?

  delegate :name_long, to: :contractor, prefix: true, allow_nil: true

  validates :contractor_id, presence: true
  validates :contractor_id, uniqueness: { scope: :contract_id }
  validates :num, :name, length: { maximum: 255 }

  accepts_nested_attributes_for :sub_contractor_specs

  def self.joins_sum_sub_specs
    joins <<-SQL.strip_heredoc
      INNER JOIN (
        SELECT
          scs.sub_contractor_id,
          sum(s.qty * scs.cost) as sum_cost,
          sum(s.qty * scs.cost_nds) sum_cost_nds
        FROM sub_contractor_specs scs
        INNER JOIN specifications s ON s.id = scs.specification_id
        GROUP BY scs.sub_contractor_id
      ) sum_sub_specs ON sub_contractors.id = sum_sub_specs.sub_contractor_id
    SQL
  end

  def total_cost
    sub_contractor_specs.sum('cost')
  end

  def total_cost_nds
    sub_contractor_specs.sum('cost_nds')
  end
end

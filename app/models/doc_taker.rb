# frozen_string_literal: true

class DocTaker < ApplicationRecord
  has_paper_trail

  belongs_to :contractor
  belongs_to :tender

  set_date_columns :register_date if oracle_adapter?

  delegate :name_inn, to: :contractor, prefix: true, allow_nil: true

  validates :contractor_id, :tender_id, presence: true
  validates :reason, length: { maximum: 1000 }, presence: true
  validates :register_date, presence: true
end

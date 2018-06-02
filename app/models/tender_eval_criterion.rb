# frozen_string_literal: true

class TenderEvalCriterion < ApplicationRecord
  has_paper_trail

  belongs_to :tender
  validates :num, :position, :name, :value, presence: true
  validates :position, :value, numericality: { only_integer: true, allow_nil: true }
  validates :num, length: { maximum: 255 }
end

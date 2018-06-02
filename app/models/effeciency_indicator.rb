# frozen_string_literal: true

class EffeciencyIndicator < ApplicationRecord
  validates :work_name, presence: true
  validates :value, presence: true, numericality: true
  validates :gkpz_year, presence: true, numericality: { only_integer: true }

  before_save :set_name

  def set_name
    self.name = EffeciencyIndicatorType.find_by(work_name: self.work_name).name
  end
end

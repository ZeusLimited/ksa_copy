# frozen_string_literal: true

class EffeciencyIndicatorType < ApplicationRecord
  validates :work_name, presence: true, uniqueness: true
  validates :name, presence: true
  validates :weight, presence: true, numericality: true

  def self.types_list
    order(:work_name).pluck(:name, :work_name)
  end
end

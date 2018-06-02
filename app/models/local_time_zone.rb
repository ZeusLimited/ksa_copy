# frozen_string_literal: true

class LocalTimeZone < ApplicationRecord
  has_paper_trail

  validates :name, :time_zone, presence: true

  has_one :declension, as: :content

  has_many :tenders, dependent: :restrict_with_error

  def name_i
    try(:name)
  end

  def timezone_example
    time_zone == 'Moscow' ? "... часов московского времени" : "... часов местного (#{name_r.mb_chars.downcase}) (... московского) времени"
  end

  def name_r
    declension.try(:name_r) || name
  end

  def name_d
    declension.try(:name_d) || name
  end
end

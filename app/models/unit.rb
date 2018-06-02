# frozen_string_literal: true

class Unit < ApplicationRecord
  def self.search(term)
    units = Unit.limit(15).order(:symbol_name)
    units = units.where("lower(symbol_name) like lower(?)", "%#{term}%")
    units.pluck(:symbol_name)
  end

  def self.default
    where(code: Constants::Units::DEFAULT_UNIT).first
  end
end

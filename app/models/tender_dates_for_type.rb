# frozen_string_literal: true

class TenderDatesForType < ApplicationRecord

  belongs_to :tender_type, class_name: 'Dictionary', foreign_key: 'tender_type_id'

  delegate :fullname, :name, to: :tender_type, prefix: true

  validates :days, numericality: { only_integer: true },  length: { maximum: 3 }, presence: true

end

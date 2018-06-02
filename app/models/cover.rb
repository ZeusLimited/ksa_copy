# frozen_string_literal: true

class Cover < ApplicationRecord
  has_paper_trail

  belongs_to :bidder
  belongs_to :type, class_name: 'Dictionary', foreign_key: 'type_id'

  compound_datetime_fields :register_time

  validates :delegate, :provision, :register_num, length: { maximum: 255 }
  validates :type_id, numericality: { only_integer: true }, presence: true

  delegate :name, to: :type, prefix: true, allow_nil: true

  scope :by_type, ->(type) { where(type_id: type) }
end

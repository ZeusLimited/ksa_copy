# frozen_string_literal: true

class Direction < ApplicationRecord
  has_paper_trail

  enum type_id: { routine: 0, invest: 1 }

  has_many :plan_specifications, dependent: :restrict_with_error
  has_many :specifications, dependent: :restrict_with_error

  validates :type_id, :name, :fullname, presence: true
  validates :is_longterm, inclusion: { in: [true, false] }

  scope :longterms, -> { where(is_longterm: true) }
  scope :inivp, -> { where("yaml_key like 'inivp%'") }

  before_save :set_position
  def set_position
    return if position
    self.position = Direction.maximum(:position).to_i + 1
  end

  class << self
    def collection_for_select
      select(:name, :id, :fullname).order(:position).map { |t| [t.name, t.id, { 'title' => t.fullname }] }
    end

    def priorities
      order('type_id desc, position').each_with_index.map do |i, index|
        [i.id, index]
      end.inject({}) { |h1, e| h1.merge(e[0] => e[1]) }
    end
  end
end

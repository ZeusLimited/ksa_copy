# frozen_string_literal: true

class Criterion < ApplicationRecord
  has_paper_trail

  scope :drafts, -> { where(type_criterion: 'Draft') }
  scope :evalutions, -> { where(type_criterion: 'Evalution') }

  validates :type_criterion, :list_num, :position, :name, presence: true
  validates :type_criterion, :list_num, length: { maximum: 255 }
  validates :position, numericality: { only_integer: true, allow_nil: true }

  def self.reorder(crits)
    crits.map { |e| [e.list_num.split('.').map(&:to_i), e] }.sort.each_with_index do |el, i|
      crit = el[1]
      crit.position = i + 1
      crit.save
    end
  end

  def fullname
    "#{list_num} #{name}"
  end
end

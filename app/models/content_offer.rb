# frozen_string_literal: true

class ContentOffer < ApplicationRecord
  has_paper_trail

  belongs_to :content_offer_type, class_name: 'Dictionary', foreign_key: 'content_offer_type_id'

  def self.reorder(rows = all)
    rows.map { |e| [e.num.split('.').map(&:to_i), e] }.sort.each_with_index do |el, i|
      crit = el[1]
      crit.position = i + 1
      crit.save
    end
  end

  def fullname
    "#{num} #{name} (#{content_offer_type.try(:name)})"
  end
end

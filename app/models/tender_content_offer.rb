# frozen_string_literal: true

class TenderContentOffer < ApplicationRecord
  has_paper_trail

  belongs_to :tender
  belongs_to :content_offer_type, class_name: 'Dictionary', foreign_key: 'content_offer_type_id'

  validates :num, :position, :name, presence: true
  validates :num, length: { maximum: 255 }
end

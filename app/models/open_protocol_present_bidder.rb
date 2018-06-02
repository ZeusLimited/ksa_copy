# frozen_string_literal: true

class OpenProtocolPresentBidder < ApplicationRecord
  has_paper_trail

  belongs_to :bidder
  belongs_to :open_protocol

  validates :bidder_id, :delegate, presence: true
end

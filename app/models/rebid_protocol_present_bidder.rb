# frozen_string_literal: true

class RebidProtocolPresentBidder < ApplicationRecord
  has_paper_trail

  belongs_to :bidder
  belongs_to :rebid_protocol

  validates :bidder_id, :delegate, presence: true
end

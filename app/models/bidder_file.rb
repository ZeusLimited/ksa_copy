# frozen_string_literal: true

class BidderFile < ApplicationRecord
  has_paper_trail

  belongs_to :bidder
  belongs_to :tender_file

  delegate :document, to: :tender_file, prefix: true, allow_nil: true
end

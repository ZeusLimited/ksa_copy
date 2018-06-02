# frozen_string_literal: true

class ProtocolFile < ApplicationRecord
  has_paper_trail

  belongs_to :protocol
  belongs_to :tender_file

  scope :for_lot, ->(guid) { joins(protocol: :plan_lots).guid_eq("plan_lots.guid", guid).order(created_at: :desc) }
end

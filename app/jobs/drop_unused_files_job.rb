# frozen_string_literal: true

class DropUnusedFilesJob < ApplicationJob
  include Constants
  queue_as :low_priority

  DELETE = proc do |file|
    begin
      file&.destroy
    rescue Fog::Storage::OpenStack::NotFound
      Rails.logger.info file.read_attribute(:document)
    end
  end

  REFERENCES = %i[
    plan_lots_files
    link_tender_files
    bidder_files
    protocol_files
    contract_files
    contractor_files
    order_files
  ].freeze

  def perform(scope:, date_start:, date_end:)
    TenderFile
      .public_send(scope)
      .where(created_at: Time.zone.at(date_start)..Time.zone.at(date_end))
      .includes(REFERENCES)
      .references(REFERENCES)
      .each(&DELETE)
  end
end

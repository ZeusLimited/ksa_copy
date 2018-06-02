# frozen_string_literal: true

module Observers
  module PlanLotObserver
    extend ActiveSupport::Concern

    included do
      after_save :manage_eis_num
      after_destroy :destroy_eis_num
    end

    def manage_eis_num
      return if status_id ==  Constants::PlanLotStatus::IMPORT || EisPlanLot.where(plan_lot_guid: guid, year: announce_date.year).exists?
      EisPlanLot.create(
        plan_lot_guid: guid,
        year: announce_date.year,
        num: PlanLot.where(guid: guid)
                    .where('extract(year from announce_date) = ?', announce_date.year)
                    .where.not(status_id: Constants::PlanLotStatus::IMPORT)
                    .order(:created_at, :id)
                    .first
                    .id,
      )
    end

    def destroy_eis_num
      return if PlanLot.where(guid: guid)
                       .where('extract(year from announce_date) = ?', announce_date.year)
                       .exists?
      eis&.destroy
    end
  end
end

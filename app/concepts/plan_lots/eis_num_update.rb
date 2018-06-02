# frozen_string_literal: true

module PlanLots
  class EisNumUpdate < ApplicationOperation
    extend Contract::DSL
    contract do
      property :num
    end

    step Model(EisPlanLot, :find_by)
    step Contract::Build()
    step Contract::Validate(key: :eis_plan_lot)
    step Contract::Persist()
  end
end

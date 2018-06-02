# frozen_string_literal: true

class EisPlanLotsController < ApplicationController
  authorize_resource

  def update
    run PlanLots::EisNumUpdate
  end
end

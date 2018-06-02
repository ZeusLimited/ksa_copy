class ControlPlanLotsController < ApplicationController
  layout false

  def create_list
    authorize! :create_list, ControlPlanLot
    ControlPlanLot.create_list(current_user)
    redirect_to url_to_session_or_default(:filter_path, plan_lots_path), notice: t('.notice')
  end

  def delete_list
    authorize! :delete_list, :control_plan_lot
    ControlPlanLot.delete_list(current_user)
    redirect_to url_to_session_or_default(:filter_path, plan_lots_path), notice: t('.notice')
  end
end

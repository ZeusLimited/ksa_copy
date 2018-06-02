class PlanLotNonExecutionsController < ApplicationController
  before_action :set_plan_lot_current_version

  def index; end

  def create
    @plan_lot_non_execution = @plan_lot_current_version.non_executions.build(plan_lot_non_execution_params)
    @plan_lot_non_execution.user = current_user
    if @plan_lot_non_execution.save
      redirect_to plan_lot_non_execution_path(params[:guid])
    else
      render :index
    end
  end

  private

  def set_plan_lot_current_version
    @plan_lot_current_version = PlanLot.current_version(params[:guid])
  end

  def plan_lot_non_execution_params
    params.require(:plan_lot_non_execution).permit(:reason)
  end
end

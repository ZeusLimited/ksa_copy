class UserPlanLotsController < ApplicationController
  authorize_resource class: false
  before_action :render_index

  def index; end

  def select_list
    current_user.add_plan_lot_ids(params[:plan_lot_ids])
    respond_to do |format|
      format.html do
        redirect_to history_plan_lot_path(PlanLot.find(params[:plan_lot_ids][0]).guid_hex), notice: t('.notice')
      end
      format.js { render :index }
    end
  end

  def unselect_list
    current_user.remove_plan_lot_ids(params[:plan_lot_ids])
    render :index
  end

  def unselect_all
    current_user.clear_plan_lots
    render :index
  end

  private

  def render_index
    @plan_selected_lots = current_user.plan_lots.order(:num_tender, :num_lot).page params[:page_sel]
  end
end

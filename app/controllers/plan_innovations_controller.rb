class PlanInnovationsController < ApplicationController
  def show
    @plan_lot = Innovations::PlanLotForm.find(params[:id])
  end

  def new
    @plan_lot = Innovations::PlanLotForm.build_project(current_user.id)
  end

  def create
    @plan_lot = Innovations::PlanLotForm.new(plan_innovation_params.merge(user_id: current_user.id))

    if @plan_lot.save
      redirect_to plan_innovation_url(@plan_lot)
    else
      render :new
    end
  end

  def edit
    @plan_lot = Innovations::PlanLotForm.find(params[:id])
  end

  def update
    @plan_lot = Innovations::PlanLotForm.find(params[:id])
    @plan_lot.assign_attributes(plan_innovation_params.merge(user_id: current_user.id))

    @plan_innovation = @plan_lot.deep_clone include: { plan_specifications: :production_units }

    @plan_innovation.include_ipivp = true

    if @plan_innovation.save
      redirect_to plan_innovation_url(@plan_innovation)
    else
      @plan_lot.valid?
      render :edit
    end
  end

  private

  def plan_innovation_params
    params.require(:plan_lot).permit(
      :num_tender, :num_lot, :announce_year, :subject_type_id, :lot_name, :order1352_fullname, :order1352_id,
      :delivery_year_begin, :delivery_year_end, :gkpz_year,
      plan_specifications_attributes: [:direction_id, :financing_id, :customer_id, :consumer_id, :monitor_service_id,
                                       :curator, :tech_curator, :okdp_id, :okved_id, :consumer_id, :requirements,
                                       :id, production_unit_ids: []])
  end
end

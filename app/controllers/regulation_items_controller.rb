class RegulationItemsController < ApplicationController
  load_and_authorize_resource

  def index
    if params[:department].present?
      @regulation_items = @regulation_items.dep_own_item(params[:department].to_i).order(is_actual: :desc, num: :asc)
    else
      @regulation_items = @regulation_items.order(is_actual: :desc, num: :asc)
    end
  end

  def new; end

  def edit; end

  def create
    if @regulation_item.save
      redirect_to regulation_items_url, notice: t('.notice')
    else
      render :new
    end
  end

  def update
    if @regulation_item.update(regulation_item_params)
      redirect_to regulation_items_url, notice: t('.notice')
    else
      render :edit
    end
  end

  def destroy
    @regulation_item.destroy
    redirect_to regulation_items_url, notice: t('.notice')
  end

  def for_type
    root_cus_id = Department.find(params[:department_id]).root_id.to_i
    @regulation_items = RegulationItem.actuals.dep_own_item(root_cus_id).for_type(params[:tender_type_id])
    render json: @regulation_items
  end

  private

  def regulation_item_params
    params.require(:regulation_item).permit(
      :num, :name, :is_actual, tender_type_ids: [], department_ids: [], dictionary_ids: []
    )
  end
end

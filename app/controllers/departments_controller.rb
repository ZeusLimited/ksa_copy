class DepartmentsController < ApplicationController
  load_and_authorize_resource

  def index; end

  def show; end

  def new; end

  def new_child
    @department = Department.new
  end

  def edit; end

  def edit_child; end

  def create
    @department.parent_id = department_params[:parent_dept_id]
    if @department.save
      redirect_to departments_url, notice: t('.notice')
    else
      render "new#{department_params[:is_child] && '_child'}"
    end
  end

  def update
    @department.parent_id = department_params[:parent_dept_id]
    if @department.update_attributes(department_params)
      redirect_to departments_url, notice: t('.notice')
    else
      render "edit#{department_params[:is_child] && '_child'}"
    end
  end

  def search
    @deps = Department.search(params[:term], current_user.root_dept_id, params[:scope])
    render json: @deps
  end

  def nodes_for_index
    nodes = Department.for_index
    logger.info nodes.to_yaml
    render json: nodes
  end

  def nodes_for_filter
    nodes = Department.nodes_for_filter(params[:filter])
    render json: nodes
  end

  def nodes_for_parent
    nodes = Department.nodes_for_parent(params[:dept_id])
    render json: nodes
  end

  private

  def department_params
    params.require(:department).permit(
      :name, :etp_id, :fact_address, :is_customer, :is_organizer, :legal_address, :inn, :kpp, :is_child, :shortname,
      :parent_id, :parent_dept_id, :parent, :position, :fullname, :tender_cost_limit_money, :ownership, :full_ownership,
      :ownership_id, :eis223_limit_money, contact_attributes: [:id, :department_id, :phone, :fax, :web, :email,
      :legal_fias_id, :postal_fias_id, :contact_person]
    )
  end
end

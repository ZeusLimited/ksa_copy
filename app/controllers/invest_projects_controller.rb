class InvestProjectsController < ApplicationController
  before_action :set_invest_project, only: [:show, :edit, :update, :destroy]
  authorize_resource

  layout false, only: [:filter_rows_for_select]

  def index
    @years = 2010..Time.now.year + 1
    if params[:year].present?
      session[:filter_invest_path] = request.env["REQUEST_URI"]
      @invest_projects = InvestProject.by_year_and_dep(params[:year], params[:department])
    else
      @invest_projects = []
    end
  end

  def show; end

  def new
    @invest_project = InvestProject.new
  end

  def edit; end

  def create
    @invest_project = InvestProject.new(invest_project_params)

    if @invest_project.save
      redirect_to url_to_session_or_default(:filter_invest_path, @invest_project), notice: t('.notice')
    else
      render :new
    end
  end

  def update
    if @invest_project.update_attributes(invest_project_params)
      redirect_to url_to_session_or_default(:filter_invest_path, @invest_project), notice: t('.notice')
    else
      render :edit
    end
  end

  def destroy
    @invest_project.destroy

    redirect_to url_to_session_or_default(:filter_invest_path, invest_projects_url)
  end

  def filter_rows_for_select
    @invest_projects = InvestProject.by_year_and_dep(params[:year], params[:department])
    @invest_id = params[:invest_id]
  end

  def filter_invest_names
    @invest_project_names = InvestProjectName.filter(params[:q], params[:dep_id]).limit(10)
    render json: @invest_project_names
  end

  private

  def set_invest_project
    @invest_project = InvestProject.find(params[:id])
  end

  def invest_project_params
    params.require(:invest_project).permit(
      :amount_financing, :amount_financing_money, :date_install, :department_id, :name, :num, :object_name,
      :power_elec_gen, :power_elec_net, :invest_project_name_id,
      :power_substation, :power_thermal_gen, :power_thermal_net, :gkpz_year, :project_type_id)
  end
end

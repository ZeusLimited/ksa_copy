class CommissionsController < ApplicationController
  authorize_resource

  def index
    if params[:department].present?
      session[:filter_commission_path] = request.env["REQUEST_URI"]
      @commissions = Commission.where(department_id: params[:department]).order(:name)
    else
      @commissions = []
    end
  end

  def show
    @commission = Commission.find(params[:id])
  end

  def new
    @commission = Commission.new(department_id: params[:department])
  end

  def edit
    @commission = Commission.find(params[:id])
  end

  def create
    @commission = Commission.new(commission_params)
    @commission.is_actual = true

    if @commission.save
      redirect_to url_to_session_or_default(:filter_commission_path, @commission), notice: t('.notice')
    else
      render :new
    end
  end

  def update
    @commission = Commission.find(params[:id])

    if @commission.update_attributes(commission_params)
      redirect_to url_to_session_or_default(:filter_commission_path, @commission), notice: t('.notice')
    else
      render :edit
    end
  end

  def destroy
    @commission = Commission.find(params[:id])
    notice = @commission.destroy ? { notice: t('.notice') } : { alert: t('.alert') }

    redirect_to url_to_session_or_default(:filter_commission_path, commissions_url), notice
  end

  def for_organizer
    render json: Commission.for_organizer(params[:org_id])
  end

  private

  def commission_params
    params.require(:commission).permit(
      :commission_type_id, :department_id, :is_actual, :name, :for_customers,
      commission_users_attributes: [
        :commission_id, :is_veto, :status, :user_id, :user_name, :user_job, :status_name, :id, :_destroy
      ])
  end
end

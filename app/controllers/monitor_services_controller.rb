class MonitorServicesController < ApplicationController
  load_and_authorize_resource

  def index
    @monitor_services = MonitorService.all.joins(:department).order("fullname")
  end

  def new
    @monitor_service = MonitorService.new
  end

  def create
    @monitor_service = MonitorService.new(monitor_service_params)

    if @monitor_service.save
      redirect_to monitor_services_url, notice: t('.notice')
    else
      render :new
    end
  end

  def destroy
    @monitor_service.destroy
    redirect_to monitor_services_url, notice: t('.notice')
  end

  private

  def monitor_service_params
    params.require(:monitor_service).permit(:id,:department_id)
  end
end

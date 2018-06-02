class TenderRequestsController < ApplicationController
  authorize_resource
  before_action :set_tender, except: :destroy
  before_action :set_tender_request, only: [:show, :edit, :update, :destroy]

  decorates_assigned :tender

  def index
    @tender_requests = @tender.tender_requests
  end

  def show; end

  def new
    @tender_request = @tender.tender_requests.build
  end

  def edit; end

  def create
    @tender_request = @tender.tender_requests.build(tender_request_params)

    if @tender_request.save
      redirect_to tender_tender_requests_path, notice: t('.notice')
    else
      render :new
    end
  end

  def update
    if @tender_request.update_attributes(tender_request_params)
      redirect_to tender_tender_requests_path, notice: t('.notice')
    else
      render :edit
    end
  end

  def destroy
    @tender_request.destroy

    redirect_to tender_tender_requests_path, notice: t('.notice')
  end

  private

  def set_tender
    @tender = Tender.find(params[:tender_id])
  end

  def set_tender_request
    @tender_request = TenderRequest.find(params[:id])
  end

  def tender_request_params
    params.require(:tender_request).permit(
      :tender_id, :contractor_text, :inbox_date, :inbox_num, :outbox_date, :outbox_num,
      :register_date, :request, :user_name, :user_id)
  end
end

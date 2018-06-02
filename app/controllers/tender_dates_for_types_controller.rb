class TenderDatesForTypesController < ApplicationController
  load_and_authorize_resource param_method: :tender_dates_for_type_params, except: :new

  decorates_assigned :tender_dates_for_type

  before_action :set_tender_dates_for_type, only: [:show, :edit, :update, :destroy]

  def index
    @tender_dates_for_types = TenderDatesForType.all
  end

  def show
  end

  def new
    @tender_dates_for_type = TenderDatesForType.new
  end

  def edit
  end

  def create
    @tender_dates_for_type = TenderDatesForType.new(tender_dates_for_type_params)
    if @tender_dates_for_type.save
      redirect_to tender_dates_for_types_path, notice: t('.notice')
    else
      render :new
    end
  end

  def update
    if @tender_dates_for_type.update(tender_dates_for_type_params)
      redirect_to tender_dates_for_types_path, notice: t('.notice')
    else
      render :edit
    end
  end

  def destroy
    @tender_dates_for_type.destroy
    redirect_to tender_dates_for_types_url, notice: t('.notice')
  end

  private
    def set_tender_dates_for_type
      @tender_dates_for_type = TenderDatesForType.find(params[:id])
    end

    def tender_dates_for_type_params
      params.require(:tender_dates_for_type).permit(:days, :tender_type_id)
    end
end

class EffeciencyIndicatorsController < ApplicationController
  authorize_resource

  def new
    @effeciency_indicator = EffeciencyIndicator.new
  end

  def edit
    @effeciency_indicator = EffeciencyIndicator.find(params[:id])
  end

  def index
    @effeciency_indicators = EffeciencyIndicator.order(gkpz_year: :desc)
  end

  def create
    @effeciency_indicator = EffeciencyIndicator.new(indicators_params)
    if @effeciency_indicator.save
      redirect_to effeciency_indicators_url(@effeciency_indicator), notice: t('.notice')
    else
      render :new
    end
  end

  def update
    @effeciency_indicator = EffeciencyIndicator.find(params[:id])
    if @effeciency_indicator.update(indicators_params)
      redirect_to effeciency_indicators_url(@effeciency_indicator), notice: t('.notice')
    else
      render :edit
    end
  end

  def destroy
    @effeciency_indicator = EffeciencyIndicator.find(params[:id])
    @effeciency_indicator.destroy
    redirect_to effeciency_indicators_url, notice: t('.notice')
  end

  private

  def indicators_params
    params.require(:effeciency_indicator).permit(:work_name, :gkpz_year, :value, :name)
  end
end

class ResultProtocolsController < ApplicationController
  include Constants
  load_and_authorize_resource :tender
  load_and_authorize_resource through: :tender
  decorates_assigned :tender, :result_protocol

  before_action :authorize_tender
  before_action :authorize_lots, only: [:new, :create]

  def index; end

  def show; end

  def new
    @result_protocol.num = "#{@tender.num}-И"
  end

  def edit; end

  def create
    if @result_protocol.save
      redirect_to [@tender, @result_protocol], notice: t('.notice')
    else
      render :new
    end
  end

  def update
    if @result_protocol.update(result_protocol_params)
      redirect_to [@tender, @result_protocol], notice: t('.notice')
    else
      render :edit
    end
  end

  def destroy
    @result_protocol.destroy

    redirect_to tender_result_protocols_path(@tender), notice: t('.notice')
  end

  def sign
    change_status(LotStatus::WINNER, LotStatus::RP_SIGN)
  end

  def revoke_sign
    change_status(LotStatus::RP_SIGN, LotStatus::WINNER)
  end

  private

  def authorize_tender
    authorize! :tender_auction?, @tender
  end

  def authorize_lots
    authorize! :have_lots_for_result_protocol?, @tender
  end

  def change_status(status_current, status_next)
    Lot.change_status(@result_protocol.lots, status_current, status_next)

    redirect_to [@tender, @result_protocol], notice: t('.notice')
  end

  def result_protocol_params
    pars = params.require(:result_protocol)
      .permit(:num, :sign_date, :sign_city,
              result_protocol_lots_attributes: [:id, :enable, :lot_id, :result_protocol_id, :_destroy])
    if pars[:result_protocol_lots_attributes]
      pars[:result_protocol_lots_attributes].values.each do |rl_attr|
        rl_attr[:_destroy] = true if rl_attr[:enable] != '1'
      end
    end
    pars
  end
end

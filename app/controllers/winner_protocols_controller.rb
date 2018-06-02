class WinnerProtocolsController < ApplicationController
  include Constants
  load_and_authorize_resource :tender
  load_and_authorize_resource through: :tender

  decorates_assigned :tender, :winner_protocol

  layout false, only: :update_confirm_date

  def index; end

  def show; end

  def new
    @winner_protocol.num = "#{@tender.num}-ВП"
  end

  def edit; end

  def create
    if @winner_protocol.save
      redirect_to [@tender, @winner_protocol], notice: t('.notice')
    else
      render :new
    end
  end

  def update
    if @winner_protocol.update(winner_protocol_params)
      redirect_to [@tender, @winner_protocol], notice: t('.notice')
    else
      render :edit
    end
  end

  def destroy
    @winner_protocol.destroy
    redirect_to tender_winner_protocols_url, notice: t('.notice')
  end

  def pre_confirm
    change_status(LotStatus::FOR_WP, LotStatus::SW)
  end

  def confirm
    change_status(LotStatus::SW, LotStatus::SW_CONFIRM)
  end

  def revoke_confirm
    change_status(LotStatus::SW_CONFIRM, LotStatus::SW)
  end

  def cancel_confirm
    @winner_protocol.winner_protocol_lots.each do |wpl|
      wpl.lot.update_attribute(:status_id, wpl.status_before_pre_confirm)
    end
    redirect_to [@tender, @winner_protocol], notice: t('.notice')
  end

  def sign
    @winner_protocol.winner_protocol_lots.each do |wpl|
      wpl.lot.update_attribute(:status_id, wpl.status_after_sign)
    end
    redirect_to [@tender, @winner_protocol], notice: t('.notice')
  end

  def revoke_sign
    change_status([LotStatus::WINNER, LotStatus::FAIL, LotStatus::CANCEL], LotStatus::SW_CONFIRM)
  end

  def update_confirm_date
    if @winner_protocol.update(confirm_date: params[:confirm_date])
      render json: { title: winner_protocol.title }
    else
      render :update_confirm_date, status: 500
    end
  end

  private

  def change_status(status_current, status_next)
    Lot.change_status(@winner_protocol.lots, status_current, status_next)

    redirect_to [@tender, @winner_protocol], notice: t('.notice')
  end

  def winner_protocol_params
    pars = params.require(:winner_protocol)
      .permit(:num, :confirm_date, :violation_reason,
              winner_protocol_lots_attributes: [:id, :enable, :lot_id, :winner_protocol_id, :_destroy,
                                                :solution_type_id])
    if pars[:winner_protocol_lots_attributes]
      pars[:winner_protocol_lots_attributes].values.each do |wl_attr|
        wl_attr[:_destroy] = true if wl_attr[:enable] != '1'
      end
    end
    pars
  end
end

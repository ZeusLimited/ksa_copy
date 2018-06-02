class ReviewProtocolsController < ApplicationController
  include ApplicationHelper
  include Constants
  load_and_authorize_resource :tender
  load_and_authorize_resource :review_protocol, through: :tender

  decorates_assigned :tender, :review_protocol

  layout false, only: :update_confirm_date

  def index; end

  def show; end

  def new
    # @review_protocol = @tender.review_protocols.build(num: "#{@tender.num}-Р")
    @review_protocol.num = "#{@tender.num}-Р"
  end

  def edit; end

  def create
    if @review_protocol.save
      redirect_to [@tender, @review_protocol], notice: t('.notice')
    else
      render :new
    end
  end

  def update
    if @review_protocol.update(review_protocol_params)
      redirect_to [@tender, @review_protocol], notice: t('.notice')
    else
      render :edit
    end
  end

  def destroy
    if @review_protocol.lots.pluck(:status_id)[0] == LotStatus::REVIEW_CONFIRM
      Lot.change_status(@review_protocol.lots, LotStatus::REVIEW_CONFIRM, LotStatus::OPEN)
    end
    @review_protocol.destroy
    redirect_to tender_review_protocols_url, notice: t('.notice')
  end

  def pre_confirm
    change_status(LotStatus::OPEN, LotStatus::REVIEW)
  end

  def confirm
    change_status(LotStatus::REVIEW, LotStatus::REVIEW_CONFIRM)
  end

  def revoke_confirm
    change_status(LotStatus::REVIEW_CONFIRM, LotStatus::REVIEW)
  end

  def cancel_confirm
    change_status(LotStatus::REVIEW, LotStatus::OPEN)
  end

  def update_confirm_date
    if @review_protocol.update(confirm_date: params[:confirm_date])
      render json: { title: review_protocol.title }
    else
      render :update_confirm_date, status: 500
    end
  end

  private

  def change_status(status_current, status_next)
    Lot.change_status(@review_protocol.lots, status_current, status_next)

    redirect_to [@tender, @review_protocol], notice: t('.notice')
  end

  def review_protocol_params
    pars = params.require(:review_protocol).permit(
      :num, :confirm_date,
      review_lots_attributes: [
        :enable, :lot_id, :id, :_destroy, :rebid_date, :review_protocol_id, :rebid_place, :rebid,
        compound_rebid_date_attributes: [:date, :time]
      ]
    )
    if pars[:review_lots_attributes]
      pars[:review_lots_attributes].values.each do |rl_attr|
        rl_attr[:_destroy] = true unless rl_attr[:enable].to_b
        unless rl_attr[:rebid].to_b
          rl_attr[:compound_rebid_date_attributes] = { date: nil, time: nil }
          rl_attr[:rebid_place] = nil
        end
      end
    end
    pars
  end
end

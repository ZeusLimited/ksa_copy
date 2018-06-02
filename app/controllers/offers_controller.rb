class OffersController < ApplicationController
  include Constants::OfferTypes
  load_and_authorize_resource :tender
  load_and_authorize_resource :bidder, through: :tender
  load_and_authorize_resource :offer, through: :bidder

  decorates_assigned :tender
  decorates_assigned :bidder
  before_action :check_and_set_offer_old, only: [:add, :control, :pickup]

  def index
    @lots = @tender.lots.order(:num)
  end

  def show; end

  def new
    @offer = @bidder.build_offer(params[:lot_id])
    respond_to do |format|
      format.html
      format.json { render :show }
    end
  end

  def create
    if @offer.save
      respond_to do |format|
        format.html { redirect_to tender_bidder_offers_path, notice: t('.notice') }
        format.json { render :show, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new }
        format.json { render json: @offer.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    fail(CanCan::AccessDenied, t('.pickup')) if @offer.type_id == PICKUP
    respond_to do |format|
      format.html
      format.json { render :show }
    end
  end

  def update
    if @offer.update_attributes(offer_params)
      respond_to do |format|
        format.html { redirect_to tender_bidder_offer_path, notice: t('.notice') }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.json { render json: @offer.errors, status: :unprocessable_entity }
      end
    end
  end

  def control
    @offer = @offer_old.clone(@type_id)
    respond_to do |format|
      format.html
      format.json { render :show }
    end
  end

  def add
    @offer = @bidder.offers.build(offer_params)
    if @offer.save
      respond_to do |format|
        format.html { redirect_to tender_bidder_offers_path(@tender, @bidder), notice: t('.notice') }
        format.json { render :show, status: :created }
      end
    else
      respond_to do |format|
        format.html { render "control" }
        format.json { render json: @offer.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @offer.destroy
    respond_to do |format|
      format.html { redirect_to tender_bidder_offers_path, notice: t('.notice') }
      format.json { head :no_content }
    end
  end

  def pickup
    @offer = @offer_old.clone(@type_id)
    if @offer.save
      respond_to do |format|
        format.html { redirect_to tender_bidder_offers_path, notice: t('.notice') }
        format.json { render :show, status: :created }
      end
    else
      respond_to do |format|
        format.html { redirect_to tender_bidder_offers_path, alert: t('.alert') }
        format.json { render json: @offer.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def check_and_set_offer_old
    @offer_old = Offer.for_bid_lot_num(@bidder.id, params[:lot_id], params[:num]).where(version: 0).first
    fail CanCan::AccessDenied, "Переход по поврежденной ссылке. Действие отменено" unless @offer_old

    @type_id = @offer_old.next_type if action_name == 'control'
    @type_id = PICKUP if action_name == 'pickup'
    
    if @offer_old.type_id == PICKUP && @type_id != OFFER
      fail CanCan::AccessDenied, "После отзыва может быть только новая оферта!"
    end
  end

  def offer_params
    params.require(:offer).permit(
      :bidder_id, :change_descriptions, :conditions, :is_winer, :lot_id, :note, :num, :type_id, :version, :status_id,
      :rebidded, :maker, :absent_auction, :final_conditions,
      offer_specifications_attributes: [
        :cost, :cost_money, :cost_nds, :cost_nds_money, :offer_id, :specification_id, :id,
        :final_cost, :final_cost_money, :final_cost_nds, :final_cost_nds_money
      ])
  end
end

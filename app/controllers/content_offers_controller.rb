class ContentOffersController < ApplicationController
  before_action :set_content_offer, only: [:show, :edit, :update, :destroy]

  # GET /content_offers
  def index
    @content_offers = ContentOffer.all
  end

  # GET /content_offers/1
  def show
  end

  # GET /content_offers/new
  def new
    @content_offer = ContentOffer.new
  end

  # GET /content_offers/1/edit
  def edit
  end

  # POST /content_offers
  def create
    @content_offer = ContentOffer.new(content_offer_params)

    if @content_offer.save
      redirect_to @content_offer, notice: 'Content offer was successfully created.'
    else
      render 'new'
    end
  end

  # PATCH/PUT /content_offers/1
  def update
    if @content_offer.update(content_offer_params)
      redirect_to @content_offer, notice: 'Content offer was successfully updated.'
    else
      render 'edit'
    end
  end

  # DELETE /content_offers/1
  def destroy
    @content_offer.destroy
    redirect_to content_offers_url, notice: 'Content offer was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
  def set_content_offer
    @content_offer = ContentOffer.find(params[:id])
  end

    # Only allow a trusted parameter "white list" through.
  def content_offer_params
    params.require(:content_offer).permit(:name, :num, :position, :content_offer_type_id)
  end
end

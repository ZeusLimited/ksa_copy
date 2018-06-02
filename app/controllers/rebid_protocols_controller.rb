class RebidProtocolsController < ApplicationController
  include Constants
  include CanCan
  load_and_authorize_resource :tender
  load_and_authorize_resource through: :tender

  decorates_assigned :tender, :rebid_protocol

  layout false, only: [:present_members]

  def index; end

  def show
    respond_to do |format|
      format.html
      format.docx { generate_document("rebid_protocol.docx") }
    end
  end

  def new
    @rebid_protocol = @tender.rebid_protocol_build
  end

  def edit
    @rebid_protocol.rebid_lots = (@tender.lots.for_rebid_protocol + @rebid_protocol.lots).map do |lot|
      { 'id' => lot.id.to_s, 'selected' => lot.rebid_protocol_id == @rebid_protocol.id ? '1' : '0' }
    end
  end

  def create
    if @rebid_protocol.save
      redirect_to tender_rebid_protocols_path(@tender), notice: t('.notice')
    else
      render :new
    end
  end

  def update
    if @rebid_protocol.update(rebid_protocol_params)
      redirect_to tender_rebid_protocols_path(@tender), notice: t('.notice')
    else
      render :edit
    end
  end

  def destroy
    @rebid_protocol.destroy

    redirect_to tender_rebid_protocols_url, notice: t('.notice')
  end

  def present_members
    if params[:rebid_protocol_id].present?
      @rebid_protocol = RebidProtocol.find(params[:rebid_protocol_id])
    else
      @rebid_protocol = @tender.rebid_protocols.build
    end
    @rebid_protocol.commission = Commission.find(params[:commission_id])
  end

  def reference
    generate_document("rebid_reference.docx")
  end

  private

  def rebid_protocol_params
    pars = params.require(:rebid_protocol).permit(:tender_id, :num, :confirm_date, :confirm_city, :commission_id,
                                                  :resolve, :clerk_id, :location,
                                                  compound_rebid_date_attributes: [:date, :time],
                                                  rebid_lots_attributes: [:id, :selected],
                                                  rebid_protocol_present_members_attributes: [
                                                    :open_protocol_id, :status_id, :user_id, :status_name,
                                                    :enable, :id, :_destroy],
                                                  rebid_protocol_present_bidders_attributes: [
                                                    :bidder_id, :delegate, :open_protocol_id, :id, :_destroy])
    if pars[:rebid_protocol_present_members_attributes]
      pars[:rebid_protocol_present_members_attributes].values.each do |rp_attr|
        rp_attr[:_destroy] = true unless rp_attr[:enable].to_b
      end
    end
    pars
  end
end

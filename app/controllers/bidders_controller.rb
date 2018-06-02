require 'zip'
class BiddersController < ApplicationController
  load_and_authorize_resource :tender
  load_and_authorize_resource :bidder, through: :tender

  decorates_assigned :tender
  decorates_assigned :bidder

  def index
    @bidders = @tender.bidders.order_by_name
  end

  def show; end

  def new
    @bidder = @tender.bidders.build
    @bidder.covers.build
  end

  def edit; end

  def create
    @bidder = @tender.bidders.build(bidder_params)
    respond_to do |format|
      if @bidder.save
        format.html { redirect_to tender_bidders_url(@tender), notice: t('.notice') }
        format.json { render json: @bidder, status: :created }
      else
        format.html { render :new }
        format.json { render json: @bidder.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @bidder.update_attributes(bidder_params)
        format.json { render json: @bidder, status: :ok }
        format.html { redirect_to tender_bidder_url(@tender, @bidder), notice: t('.notice') }
      else
        format.html { render :edit }
        format.json { render json: @bidder.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @bidder.destroy

    redirect_to tender_bidders_url(@tender), notice: t('.notice')
  end

  def map_by_lot
    @bidders = @tender.bidders
  end

  def map_pivot
    @bidders = @tender.bidders
  end

  def all_files_as_one
    compress_and_send_files(@bidder.tender_files, [bidder.contractor_name_short, bidder.id].join('-'))
  end

  def file_exists
    render json: { exists: @bidder.tender_files.where(external_filename: params[:file_name]).exists? }
  end

  private

  def bidder_params
    params.require(:bidder).permit(
      :contractor_id, :is_presence, :tender_id,
      covers_attributes: [
        :bidder_id, :delegate, :provision, :register_num, :type_id, :id, :_destroy,
        compound_register_time_attributes: [:date, :time]
      ],
      bidder_files_attributes: [
        :note, :tender_file_id, :id, :_destroy
      ])
  end
end

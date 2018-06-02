class OpenProtocolsController < ApplicationController
  include Constants
  include CanCan

  load_and_authorize_resource :tender
  load_and_authorize_resource through: :tender, singleton: true

  decorates_assigned :tender
  decorates_assigned :open_protocol

  before_action :check_before_new, only: [:new]

  layout false, only: [:present_members]

  def show
    @covers = Cover.joins(:bidder).where("tender_id = ?", @tender.id)
    @offers = Offer.joins(:bidder).where("tender_id = ?", @tender.id)

    respond_to do |format|
      format.html
      format.docx { generate_document("open_protocol.docx") }
    end
  end

  def reference
    generate_document("open_reference.docx")
  end

  def new
    @open_protocol = @tender.open_protocol_build
  end

  def edit
    return unless @tender.commission
    @users = @tender.commission.commission_users.joins(:user).order("status, surname, name, patronymic")
  end

  def create
    respond_to do |format|
      if @open_protocol.save
        Lot.change_status(@tender.lots, LotStatus::PUBLIC, LotStatus::OPEN)
        format.json { render json: @open_protocol, status: :ok }
        format.html { redirect_to tender_open_protocol_path(@tender, @open_protocol), notice: t('.notice') }
      else
        format.json { render json: @open_protocol.errors, status: :unprocessable_entity }
        format.html { render :new }
      end
    end
  end

  def update
    if @open_protocol.update_attributes(open_protocol_params)
      redirect_to tender_open_protocol_path, notice: t('.notice')
    else
      render :edit
    end
  end

  def destroy
    fail AccessDenied, t('.after_open') if @tender.lots_with_status?(LotStatus::AFTER_OPEN)
    @open_protocol.destroy
    Lot.change_status(@tender.lots, LotStatus::OPEN, LotStatus::PUBLIC)

    redirect_to tender_bidders_url, notice: t('.notice')
  end

  def present_members
    if params[:open_protocol_id].present?
      @open_protocol = OpenProtocol.find(params[:open_protocol_id])
    else
      @open_protocol = @tender.build_open_protocol
    end
    @open_protocol.commission = Commission.find(params[:commission_id])
  end

  private

  def check_before_new
    fail AccessDenied, t('.no_commission') unless Commission.for_organizer(@tender.department_id).present?
  end

  def open_protocol_params
    pars = params.require(:open_protocol).permit(
      :clerk_id, :location, :num, :open_date, :resolve, :sign_city, :sign_date, :tender_id, :commission_id,
      compound_open_date_attributes: [:date, :time],
      open_protocol_present_members_attributes: [
        :open_protocol_id, :status_id, :user_id, :status_name, :enable, :id, :_destroy
      ],
      open_protocol_present_bidders_attributes: [
        :bidder_id, :delegate, :open_protocol_id, :id, :_destroy
      ])
    if pars[:open_protocol_present_members_attributes]
      pars[:open_protocol_present_members_attributes].values.each do |op_attr|
        op_attr[:_destroy] = true if op_attr[:enable] != '1'
      end
    end
    pars
  end
end

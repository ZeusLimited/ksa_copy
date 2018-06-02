class ContractsController < ApplicationController
  before_action :set_tender_lot
  before_action :set_contract, only: [:show, :edit, :update, :destroy]

  authorize_resource :offer
  authorize_resource through: :offer, singleton: true

  decorates_assigned :tender
  decorates_assigned :contract

  def show
    render contract.show_template
  end

  def new
    authorize! :create_contract, @lot
    @contract = @offer.build_contract_with_specs
  end

  def edit
    render contract.edit_template
  end

  def create
    authorize! :create_contract, @lot
    @contract = @offer.build_contract(contract_params)
    @contract.lot = @lot

    if @contract.save
      redirect_to offer_contract_url(@offer), notice: t('.notice')
    else
      render :new
    end
  end

  def update
    if @contract.update(contract_params)
      redirect_to offer_contract_url(@offer), notice: t('.notice')
    else
      render :edit
    end
  end

  def destroy
    @contract.destroy
    redirect_to tender.only_source? ? tender_path(@tender) : contracts_tender_url(@tender), notice: t('.notice')
  end

  def additional_search
    @contracts = Contract.additional_search(params[:q], @lot.root_customer_id).select_title_fields.limit(10)
  end

  def additional_info
    @contract = Contract.joins(:lot).select_title_fields.find(params[:id])
  end

  private

  def set_tender_lot
    @offer = Offer.find(params[:offer_id])
    @lot = @offer.lot
    @tender = @lot.tender
  end

  def set_contract
    @contract = @offer.contract
    fail ActiveRecord::RecordNotFound if @contract.nil?
  end

  def contract_params
    params.require(:contract).permit(
      :num, :confirm_date, :delivery_date_begin, :delivery_date_end, :parent_id, :non_delivery_reason,
      :reg_number,
      contract_files_attributes: [
        :_destroy, :tender_file_id, :id, :file_type_id, :note
      ],
      contract_specifications_attributes: [
        :specification_id, :cost_money, :cost_nds_money, :id,
        contract_amounts_attributes: [
          :year, :amount_finance_money, :amount_finance_nds_money, :id, :_destroy
        ]
      ]
    )
  end
end

class ContractReductionsController < ApplicationController
  before_action :set_tender_lot
  before_action :set_contract, only: [:show, :edit, :update, :destroy]

  def index
    authorize! :show, @tender
    @contracts = Contract.where(parent: @basic_contract).basics.order_by_date
    @reductions = @offer.reduction_contracts
  end

  def new
    @contract = @offer.build_reduction_contract_with_specs
    authorize! :new, @contract
  end

  def create
    @contract = @offer.reduction_contracts.build(contract_params)
    @contract.parent_id = @offer.contract.id
    @contract.lot = @lot
    authorize! :create, @contract

    if @contract.save
      redirect_to contract_contract_reduction_url(@basic_contract, @contract), notice: t('.notice')
    else
      render :new
    end
  end

  def show
    authorize! :show, @contract
  end

  def edit
    authorize! :edit, @contract
  end

  def update
    authorize! :update, @contract
    if @contract.update(contract_params)
      redirect_to contract_contract_reduction_url(@basic_contract, @contract), notice: t('.notice')
    else
      render :edit
    end
  end

  def destroy
    authorize! :destroy, @contract
    @contract.destroy
    redirect_to contract_contract_reductions_url(@basic_contract), notice: t('.notice')
  end

  private

  def set_tender_lot
    @basic_contract = Contract.find(params[:contract_id])
    @offer = @basic_contract.offer
    @lot = @basic_contract.lot
    @tender = @lot.tender
  end

  def set_contract
    @contract = Contract.find(params[:id])
  end

  def contract_params
    params.require(:contract).permit(
      :num, :confirm_date, :delivery_date_begin, :delivery_date_end,
      contract_specifications_attributes: [
        :specification_id, :cost_money, :cost_nds_money, :id
      ]
    )
  end
end

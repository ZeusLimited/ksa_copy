class ContractTerminationsController < ApplicationController
  before_action :set_tender_lot_contract
  before_action :set_contract_termination, only: [:show, :edit, :update, :destroy]

  def show; end

  def new
    @contract_termination = @contract.build_contract_termination
  end

  def edit; end

  def create
    @contract_termination = @contract.build_contract_termination(contract_termination_params)

    if @contract_termination.save
      redirect_to contract_contract_termination_url(@contract), notice: t('.notice')
    else
      render :new
    end
  end

  def update
    if @contract_termination.update(contract_termination_params)
      redirect_to contract_contract_termination_url(@contract), notice: t('.notice')
    else
      render :edit
    end
  end

  def destroy
    @contract_termination.destroy
    redirect_to offer_contract_url(@contract.offer), notice: t('.notice')
  end

  private

  def set_tender_lot_contract
    @contract = Contract.find(params[:contract_id])
    @lot = @contract.lot
    @tender = @lot.tender.decorate
  end

  def set_contract_termination
    @contract_termination = @contract.contract_termination
  end

  def contract_termination_params
    params.require(:contract_termination).permit(:contract_id, :type_id, :cancel_date, :unexec_cost_money)
  end
end

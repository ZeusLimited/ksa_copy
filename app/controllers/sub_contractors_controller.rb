class SubContractorsController < ApplicationController
  authorize_resource

  before_action :set_tender_lot_contract
  before_action :set_sub_contractor, only: [:show, :edit, :update, :destroy]

  def index
    @sub_contractors = @contract.sub_contractors
  end

  def show; end

  def new
    @sub_contractor = @contract.build_sub_contractor
  end

  def edit; end

  def create
    @sub_contractor = @contract.sub_contractors.build(sub_contractor_params)
    if @sub_contractor.save
      redirect_to contract_sub_contractor_url(@contract, @sub_contractor), notice: t('.notice')
    else
      render :new
    end
  end

  def update
    if @sub_contractor.update(sub_contractor_params)
      redirect_to contract_sub_contractor_url(@contract, @sub_contractor), notice: t('.notice')
    else
      render :edit
    end
  end

  def destroy
    @sub_contractor.destroy
    redirect_to contract_sub_contractors_url(@contract), notice: t('.notice')
  end

  private

  def set_tender_lot_contract
    @contract = Contract.find(params[:contract_id])
    @offer = @contract.offer
    @lot = @contract.lot
    @tender = @lot.tender.decorate
  end

  def set_sub_contractor
    @sub_contractor = SubContractor.find(params[:id])
  end

  def sub_contractor_params
    params.require(:sub_contractor).permit(
      :contractor_id, :name, :confirm_date, :num, :begin_date, :end_date,
      sub_contractor_specs_attributes: [
        :id, :specification_id, :contract_specification_id, :cost_money, :cost_nds_money
      ]
    )
  end
end

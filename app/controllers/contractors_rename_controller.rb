class ContractorsRenameController < ApplicationController
  before_action :set_contractor_prev

  authorize_resource class: false

  def new
    @contractor = @contractor_prev.dup
  end

  def create
    @contractor = current_user.contractors.build(contractor_params)
    @contractor.prev_contractor = @contractor_prev

    if @contractor.save
      redirect_to @contractor, notice: 'Контрагент успешно переименован.'
    else
      render :new
    end
  end

  private

  def set_contractor_prev
    @contractor_prev = Contractor.find(params[:contractor_id])
    fail CanCan::AccessDenied.new unless @contractor_prev.can_rename?(current_user)
  end

  def contractor_params
    params.require(:contractor).permit(
      :name, :fullname, :inn, :kpp, :ogrn, :okpo, :ownership, :form, :legal_addr, :is_resident, :is_dzo, :is_sme,
      :jsc_form_id, :sme_type_id, :oktmo, :guid_hex, :ownership_id)
  end
end

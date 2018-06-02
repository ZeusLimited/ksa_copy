class ContractorDocumentsController < ApplicationController
  load_and_authorize_resource :contractor
  authorize_resource class: false

  def index; end

  def edit_all; end

  def update_all
    @contractor.attributes = contractor_documents_params
    @contractor.save(validate: false)
    redirect_to contractor_documents_path(@contractor)
  end

  private

  def contractor_documents_params
    params.require(:contractor).permit(files_attributes: [:id, :_destroy, :tender_file_id, :file_type_id, :note])
  end
end

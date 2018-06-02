class TenderDocumentsController < ApplicationController
  include Constants
  load_and_authorize_resource :tender
  authorize_resource class: false

  decorates_assigned :tender

  def index
  end

  def edit_all
  end

  def update_all
    @tender.attributes = tender_documents_params
    @tender.save(validate: false)
    redirect_to tender_tender_documents_path(@tender)
  end

  def tender_documents_params
    params.require(:tender).permit(
      link_tender_files_attributes: [:id, :_destroy, :tender_file_id, :file_type_id, :note])
  end

end

class ImportPlanLotsController < ApplicationController
  authorize_resource class: false

  def example
    respond_to do |format|
      format.xlsx do
        render xlsx: "example", disposition: "attachment", filename: "import.xlsx"
      end
    end
  end
end

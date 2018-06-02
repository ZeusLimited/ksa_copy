class PageFilesController < ApplicationController
  authorize_resource

  def create
    @page_file = PageFile.create(page_file_params)
  end

  def destroy
    @page_file = PageFile.find(params[:id])
    @page_file.destroy
  end

  private

  def page_file_params
    params.require(:page_file).permit(:page_id, :wikifile)
  end
end

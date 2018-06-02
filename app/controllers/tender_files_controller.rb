# frozen_string_literal: true

class TenderFilesController < ApplicationController
  authorize_resource

  def create
    workaround_brokenpipe { @tender_file = current_user.tender_files.create(tender_file_params) }
    respond_to do |format|
      format.js
      format.json { render json: @tender_file }
    end
  end

  # Временный метод для скрипта загрузки файлов из хранилища на сервер.
  def index
    @tender_files = TenderFile.where('id >= ? and id < ?', params[:id_start], params[:id_end]).order(:id)
  end

  private

  # remove method after fix bug in Excon
  def workaround_brokenpipe(&block)
    retried = false
    begin
      yield
    rescue Excon::Error::Socket => error
      unless retried
        tf = TenderFile.take
        tf.document.file.exists?
        retried = true
        retry
      else
        raise error
      end
    end
  end

  def tender_file_params
    params[:tender_file].presence &&
      params.require(:tender_file).permit(:area_id, :year, :document, :external_filename)
  end
end

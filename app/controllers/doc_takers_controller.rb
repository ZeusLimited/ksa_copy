class DocTakersController < ApplicationController
  authorize_resource
  before_action :set_tender

  def index
    @doc_takers = @tender.doc_takers.order(:register_date)
    @doc_taker = DocTaker.new
  end

  def create
    @doc_taker = DocTaker.new(doc_taker_params)
    @doc_taker.tender = @tender

    if @doc_taker.save
      redirect_to tender_doc_takers_path, notice: 'Потенциальный участник зарегистрирован.'
    else
      @doc_takers = @tender.doc_takers.order(:register_date)
      render :index
    end
  end

  def destroy
    @doc_taker = DocTaker.find(params[:id])
    @doc_taker.destroy

    redirect_to tender_doc_takers_path(@tender)
  end

  private

  def set_tender
    @tender = Tender.find(params[:tender_id]).decorate
  end

  def doc_taker_params
    params.require(:doc_taker).permit(:contractor_id, :reason, :register_date, :tender_id)
  end
end

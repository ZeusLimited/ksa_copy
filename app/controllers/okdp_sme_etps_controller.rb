class OkdpSmeEtpsController < ApplicationController
  before_action :set_okdp_sme_etp, only: [:show, :edit, :update, :destroy]

  def index
    @okdp_sme_etps = OkdpSmeEtp.search(params[:q]).order('okdp_type, code')
  end

  def show
  end

  def new
    @okdp_sme_etp = OkdpSmeEtp.new
  end

  def edit
  end

  def create
    @okdp_sme_etp = OkdpSmeEtp.new(okdp_sme_etp_params)

    if @okdp_sme_etp.save
      redirect_to okdp_sme_etps_url, notice: t('.notice')
    else
      render :new
    end
  end

  def update
    if @okdp_sme_etp.update(okdp_sme_etp_params)
      redirect_to okdp_sme_etps_url, notice: t('.notice')
    else
      render :edit
    end
  end

  def destroy
    @okdp_sme_etp.destroy
    redirect_to okdp_sme_etps_url, notice: t('.notice')
  end

  def search
    @okdp = OkdpSmeEtp.okdp_search(params[:term]).limit(15)
    render json: @okdp_sme_etp.map { |o| { id: o.id, label: o.okdp_type, value: o.code } }
  end

  private
    def set_okdp_sme_etp
      @okdp_sme_etp = OkdpSmeEtp.find(params[:id])
    end

    def okdp_sme_etp_params
      params.require(:okdp_sme_etp).permit(:code, :okdp_type)
    end
end

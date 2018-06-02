class OkdpController < ApplicationController
  authorize_resource

  def index
    @okdp = Okdp.all
    @okdp = @okdp.where(id: params[:ids].try(:split, ',')) if params[:ids].present?
  end

  def nodes_for_parent
    nodes = Okdp.by_type(params[:type]).nodes_for_parent(params[:key])
    render json: nodes
  end

  def nodes_for_filter
    nodes = Okdp.nodes_for_filter(params[:filter], params[:type])
    render json: nodes
  end

  def reform_old_value
    old_okdp = Okdp.reform_old_value(params[:new_value])
    render json: old_okdp
  end

  def show
    @okdp = Okdp.find params[:id]
  end
end

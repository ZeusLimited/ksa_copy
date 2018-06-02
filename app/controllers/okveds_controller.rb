class OkvedsController < ApplicationController
  authorize_resource

  def index
    @okved = Okved.all
    @okved = @okved.where(id: params[:ids].try(:split, ',')) if params[:ids].present?
  end

  def nodes_for_parent
    nodes = Okved.by_type(params[:type]).nodes_for_parent(params[:key])
    render json: nodes
  end

  def nodes_for_filter
    nodes = Okved.nodes_for_filter(params[:filter], params[:type])
    render json: nodes
  end

  def show
    @okved = Okved.find params[:id]
  end
end

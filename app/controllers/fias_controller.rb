class FiasController < ApplicationController
  authorize_resource class: 'Fias'

  def show
    @fias = Fias.find(params[:id])
    render json: @fias
  end

  def create
    object = Fias.by_ids(fias_params[:aoid_hex], fias_params[:houseid_hex]).take || Fias.create(fias_params.to_h)
    render json: object.as_json(except: [:aoid, :houseid], methods: [:aoid_hex, :houseid_hex])
  end

  def fias_params
    params.require(:fias).permit(:id, :aoid_hex, :houseid_hex, :name, :postalcode, :regioncode, :okato, :oktmo)
  end
end

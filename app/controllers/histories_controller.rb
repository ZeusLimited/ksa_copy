class HistoriesController < ApplicationController
  layout false
  def index
    @object = params[:type].camelize.constantize.find params[:item_id]
  end
end

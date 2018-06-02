class OwnershipsController < ApplicationController
  load_and_authorize_resource

  before_action :set_ownership, only: [:show, :edit, :update, :destroy]

  def show
  end

  def index
    @ownerships = Ownership.order(shortname: :asc)
    redux_store('SharedReduxStore', props: { ownerships: @ownerships })
  end

  def create
    @ownership = Ownership.new(ownership_params)

    if @ownership.save
      render json: @ownership
    else
      render json: @ownership.errors, status: :unprocessable_entity
    end
  end

  def update
    @ownership = Ownership.find(params[:id])
    if @ownership.update(ownership_params)
      render json: @ownership
    else
      render json: @ownership.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @ownership = Ownership.find(params[:id])
    @ownership.destroy
    head :no_content
  end

  private
    def set_ownership
      @ownership = Ownership.find(params[:id])
    end

    def ownership_params
      params.require(:ownership).permit(:shortname, :fullname)
    end
end

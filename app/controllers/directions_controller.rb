class DirectionsController < ApplicationController
  load_and_authorize_resource

  # GET /directions
  def index
    @directions = Direction.order(:position)
  end

  # GET /directions/1
  def show; end

  # GET /directions/new
  def new
    @direction = Direction.new
  end

  # GET /directions/1/edit
  def edit
  end

  # POST /directions
  def create
    @direction = Direction.new(direction_params)

    if @direction.save
      redirect_to @direction, notice: t('.notice')
    else
      render :new
    end
  end

  # PATCH/PUT /directions/1
  def update
    if @direction.update(direction_params)
      redirect_to @direction, notice: t('.notice')
    else
      render :edit
    end
  end

  # DELETE /directions/1
  def destroy
    @direction.destroy
    redirect_to directions_url, notice: t('.notice')
  end

  def sort
    params[:direction].each_with_index do |id, index|
      Direction.find(id).update(position: index)
    end
    head :ok
  end

  private

  def direction_params
    params.require(:direction).permit(:name, :fullname, :type_id, :yaml_key, :is_longterm)
  end
end

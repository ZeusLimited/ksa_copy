class LocalTimeZonesController < ApplicationController
  authorize_resource

  # GET /local_time_zones
  # GET /local_time_zones.json
  def index
    @local_time_zones = LocalTimeZone.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @local_time_zones }
    end
  end

  # GET /local_time_zones/1
  # GET /local_time_zones/1.json
  def show
    @local_time_zone = LocalTimeZone.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @local_time_zone }
    end
  end

  # GET /local_time_zones/new
  # GET /local_time_zones/new.json
  def new
    @local_time_zone = LocalTimeZone.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @local_time_zone }
    end
  end

  # GET /local_time_zones/1/edit
  def edit
    @local_time_zone = LocalTimeZone.find(params[:id])
  end

  # POST /local_time_zones
  # POST /local_time_zones.json
  def create
    @local_time_zone = LocalTimeZone.new(local_time_zone_params)

    respond_to do |format|
      if @local_time_zone.save
        format.html { redirect_to @local_time_zone, notice: 'Local time zone was successfully created.' }
        format.json { render json: @local_time_zone, status: :created, location: @local_time_zone }
      else
        format.html { render "new" }
        format.json { render json: @local_time_zone.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /local_time_zones/1
  # PUT /local_time_zones/1.json
  def update
    @local_time_zone = LocalTimeZone.find(params[:id])

    respond_to do |format|
      if @local_time_zone.update_attributes(local_time_zone_params)
        format.html { redirect_to @local_time_zone, notice: 'Local time zone was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render "edit" }
        format.json { render json: @local_time_zone.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /local_time_zones/1
  # DELETE /local_time_zones/1.json
  def destroy
    @local_time_zone = LocalTimeZone.find(params[:id])
    @local_time_zone.destroy

    respond_to do |format|
      format.html { redirect_to local_time_zones_url }
      format.json { head :no_content }
    end
  end

  private

  def local_time_zone_params
    params.require(:local_time_zone).permit(:name, :time_zone)
  end
end

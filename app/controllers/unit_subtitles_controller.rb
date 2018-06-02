class UnitSubtitlesController < ApplicationController
  # GET /unit_subtitles
  # GET /unit_subtitles.json
  def index
    @unit_subtitles = UnitSubtitle.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @unit_subtitles }
    end
  end

  # GET /unit_subtitles/1
  # GET /unit_subtitles/1.json
  def show
    @unit_subtitle = UnitSubtitle.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @unit_subtitle }
    end
  end

  # GET /unit_subtitles/new
  # GET /unit_subtitles/new.json
  def new
    @unit_subtitle = UnitSubtitle.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @unit_subtitle }
    end
  end

  # GET /unit_subtitles/1/edit
  def edit
    @unit_subtitle = UnitSubtitle.find(params[:id])
  end

  # POST /unit_subtitles
  # POST /unit_subtitles.json
  def create
    @unit_subtitle = UnitSubtitle.new(unit_subtitle_params)

    respond_to do |format|
      if @unit_subtitle.save
        format.html { redirect_to @unit_subtitle, notice: 'Unit subtitle was successfully created.' }
        format.json { render json: @unit_subtitle, status: :created, location: @unit_subtitle }
      else
        format.html { render "new" }
        format.json { render json: @unit_subtitle.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /unit_subtitles/1
  # PUT /unit_subtitles/1.json
  def update
    @unit_subtitle = UnitSubtitle.find(params[:id])

    respond_to do |format|
      if @unit_subtitle.update_attributes(unit_subtitle_params)
        format.html { redirect_to @unit_subtitle, notice: 'Unit subtitle was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render "edit" }
        format.json { render json: @unit_subtitle.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /unit_subtitles/1
  # DELETE /unit_subtitles/1.json
  def destroy
    @unit_subtitle = UnitSubtitle.find(params[:id])
    @unit_subtitle.destroy

    respond_to do |format|
      format.html { redirect_to unit_subtitles_url }
      format.json { head :no_content }
    end
  end

  private

  def unit_subtitle_params
    params.require(:unit_subtitle).permit(:name)
  end
end

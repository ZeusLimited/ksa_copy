class UnitTitlesController < ApplicationController
  # GET /unit_titles
  # GET /unit_titles.json
  def index
    @unit_titles = UnitTitle.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @unit_titles }
    end
  end

  # GET /unit_titles/1
  # GET /unit_titles/1.json
  def show
    @unit_title = UnitTitle.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @unit_title }
    end
  end

  # GET /unit_titles/new
  # GET /unit_titles/new.json
  def new
    @unit_title = UnitTitle.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @unit_title }
    end
  end

  # GET /unit_titles/1/edit
  def edit
    @unit_title = UnitTitle.find(params[:id])
  end

  # POST /unit_titles
  # POST /unit_titles.json
  def create
    @unit_title = UnitTitle.new(unit_title_params)

    respond_to do |format|
      if @unit_title.save
        format.html { redirect_to @unit_title, notice: 'Unit title was successfully created.' }
        format.json { render json: @unit_title, status: :created, location: @unit_title }
      else
        format.html { render "new" }
        format.json { render json: @unit_title.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /unit_titles/1
  # PUT /unit_titles/1.json
  def update
    @unit_title = UnitTitle.find(params[:id])

    respond_to do |format|
      if @unit_title.update_attributes(unit_title_params)
        format.html { redirect_to @unit_title, notice: 'Unit title was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render "edit" }
        format.json { render json: @unit_title.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /unit_titles/1
  # DELETE /unit_titles/1.json
  def destroy
    @unit_title = UnitTitle.find(params[:id])
    @unit_title.destroy

    respond_to do |format|
      format.html { redirect_to unit_titles_url }
      format.json { head :no_content }
    end
  end

  private

  def unit_title_params
    params.require(:unit_title).permit(:name)
  end
end

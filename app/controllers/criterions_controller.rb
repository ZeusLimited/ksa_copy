class CriterionsController < ApplicationController
  # GET /criterions
  # GET /criterions.json
  def index
    @criterions = Criterion.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @criterions }
    end
  end

  # GET /criterions/1
  # GET /criterions/1.json
  def show
    @criterion = Criterion.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @criterion }
    end
  end

  # GET /criterions/new
  # GET /criterions/new.json
  def new
    @criterion = Criterion.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @criterion }
    end
  end

  # GET /criterions/1/edit
  def edit
    @criterion = Criterion.find(params[:id])
  end

  # POST /criterions
  # POST /criterions.json
  def create
    @criterion = Criterion.new(criterion_params)

    respond_to do |format|
      if @criterion.save
        format.html { redirect_to @criterion, notice: 'Criterion was successfully created.' }
        format.json { render json: @criterion, status: :created, location: @criterion }
      else
        format.html { render "new" }
        format.json { render json: @criterion.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /criterions/1
  # PUT /criterions/1.json
  def update
    @criterion = Criterion.find(params[:id])

    respond_to do |format|
      if @criterion.update_attributes(criterion_params)
        format.html { redirect_to @criterion, notice: 'Criterion was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render "edit" }
        format.json { render json: @criterion.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /criterions/1
  # DELETE /criterions/1.json
  def destroy
    @criterion = Criterion.find(params[:id])
    @criterion.destroy

    respond_to do |format|
      format.html { redirect_to criterions_url }
      format.json { head :no_content }
    end
  end

  private

  def criterion_params
    params.require(:criterion).permit(:name, :parent_id, :type_criterion)
  end
end

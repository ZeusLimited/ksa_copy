class UnfairContractorsController < ApplicationController
  load_and_authorize_resource :unfair_contractor

  decorates_assigned :unfair_contractor

  # GET /unafair_contractors
  def index
    @unfair_contractors = UnfairContractor.order(:num).all
  end

  def lots
    @lots = Lot.joins(:tender, offers: :bidder)
      .where(["lower(lots.name) like lower(:name) or (tenders.num || '.' || lots.num) like (:num)", {name: "%#{params[:name]}%", num: "%#{params[:name]}%"} ])
      .where(bidders: { contractor_id: params[:contractor_id] })
  end

  def lots_info
    @lots = Lot.where(id: params[:lot_id].split(",").map(&:to_i))
    render :lots
  end

  # GET /unafair_contractors/1
  def show
  end

  # GET /unafair_contractors/new
  def new
    @unfair_contractor = UnfairContractor.new
  end

  # GET /unafair_contractors/1/edit
  def edit
  end

  # POST /unafair_contractors
  def create
    @unfair_contractor = UnfairContractor.new(unfair_contractor_params)
    if @unfair_contractor.save
      redirect_to @unfair_contractor, notice: 'Недобросовестный заказчик успешно создан.'
    else
      render :new
    end
  end

  # PATCH/PUT /unafair_contractors/1
  def update
    if @unfair_contractor.update(unfair_contractor_params)
      redirect_to @unfair_contractor, notice: 'Недобросовестный заказчик успешно изменен.'
    else
      render :edit
    end
  end

  # DELETE /unafair_contractors/1
  def destroy
    @unfair_contractor.destroy
    redirect_to unfair_contractors_url, notice: 'Недобросовестный заказчик успешно удален.'
  end

  def export_excel
    @unfair_contractor = UnfairContractor.includes(:contractor, lots: :tender).order(:num).all
    render xlsx: "unfair", disposition: "attachment", filename: "#{Time.now.strftime('%Y-%m-%d-%H-%M-%S')}.xlsx"
  end

  private

  def unfair_contractor_params
    params.require(:unfair_contractor).permit(:num, :date_in, :contractor_id, :contract_info, :unfair_info, :date_out, :note, :lot_ids)
  end
end

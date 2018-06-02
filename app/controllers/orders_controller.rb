class OrdersController < ApplicationController
  load_and_authorize_resource
  before_action :check_selected_plan_lots_before_order, only: [:new] # method is in application controller

  # GET /orders
  def index
    @order_filter = OrderFilter.new(order_filter_params.to_h)
    @orders = @order_filter.search

    session[:order_filter] = params[:order_filter] || {}
    respond_to do |format|
      format.html { @orders = Kaminari.paginate_array(@orders).page params[:page] }
      format.json {}
    end
  end

  # GET /orders/1
  def show; end

  # GET /orders/new
  def new
    @order.set_params(current_user)
  end

  # GET /orders/1/edit
  def edit
    @order.agreed_by_user_id ||= current_user.id
  end

  # POST /orders
  def create
    if @order.save_with_plan_lots(current_user)
      redirect_to url_to_session_or_default(:filter_path, plan_lots_path), notice: t('.notice')
    else
      render :new
    end
  end

  # PATCH/PUT /orders/1
  def update
    if @order.update(order_params)
      redirect_to @order, notice: t('.notice')
    else
      render :edit
    end
  end

  # DELETE /orders/1
  def destroy
    redirect_to orders_url,
      @order.destroy ? { notice: t('.notice') } : { alert: t('.cannot_be_deleted', num: @order.num) }
  end

  private

  def order_filter_params
    params[:order_filter]&.permit!
  end

  def order_params
    params.require(:order).permit(
      :num, :receiving_date, :agreement_date, :received_from_user_id, :agreed_by_user_id, :sort_column,
      :sort_direction, order_files_attributes: [:note, :order_id, :tender_file_id, :id, :_destroy]
    )
  end
end

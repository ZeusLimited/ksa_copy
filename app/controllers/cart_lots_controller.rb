class CartLotsController < ApplicationController
  def index
    @cart = current_user.lots
  end

  def create
    current_user.add_lot(params[:lot_id])
    render json: current_user.lots.count, status: :created
  end

  def destroy
    current_user.remove_lot(params[:id])
    respond_to do |format|
      format.html { redirect_to cart_lots_path, notice: t('.notice') }
      format.json { render json: current_user.lots.count }
    end
  end

  def clear
    current_user.clear_cart_lots
    redirect_to cart_lots_path, notice: t('.notice')
  end
end

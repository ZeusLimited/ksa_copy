# frozen_string_literal: true

class ContractExpiredsController < ApplicationController
  include ActionView::Helpers::TextHelper

  authorize_resource class: false
  before_action :set_offer
  layout false

  def edit
    render plain: @offer.non_contract_reason
  end

  def update
    if @offer.update(contract_expired_params)
      render inline: short_text(@offer.non_contract_reason)
    else
      render inline: @offer.errors.full_messages.join('<br>'), status: :conflict
    end
  end

  private

  def set_offer
    @offer = Offer.find params[:offer_id]
  end

  def contract_expired_params
    params.require(:offer).permit(:non_contract_reason)
  end
end

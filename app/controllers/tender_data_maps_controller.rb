class TenderDataMapsController < ApplicationController
  load_and_authorize_resource :tender
  authorize_resource class: false

  decorates_assigned :tender

  def show
    @tender = Tender.find(params[:tender_id])
  end

  def edit
  end

  def update
    @tender.attributes = tender_data_map_params
    @tender.b2b_classifiers = tender_data_map_params[:b2b_classifiers].split(',') \
      if tender_data_map_params[:b2b_classifiers]
    if @tender.save
      redirect_to tender_tender_data_map_path(@tender)
    else
      render :edit
    end
  end

  private

  def tender_data_map_params
    params.require(:tender)
          .permit(:life_offer, :offer_reception_place, :offer_reception_start,
                  :offer_reception_stop, :is_guarantie, :guarantie_offer,
                  :guarant_criterions, :guarantie_recvisits, :guarantie_making_money,
                  :alternate_offer, :alternate_offer_aspects, :is_gencontractor,
                  :hidden_offer, :agency_contract_num, :agency_contract_date,
                  :b2b_classifiers, :price_begin_limited,
                  lots_attributes: [:guarantie_cost, :id, :step_increment])
  end
end

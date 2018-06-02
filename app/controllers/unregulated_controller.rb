class UnregulatedController < ApplicationController
  def new
    check_selected_plan_lots # ApplicationController
    @tender = Unregulated::TenderForm.build_from_plan_selected(current_user)
    authorize! :new, @tender
  end

  def create
    @tender = Unregulated::TenderForm.new(unregulated_params)
    authorize! :create, @tender
    @tender.update_other_attributes

    if @tender.save
      redirect_to @tender, notice: t('.notice')
    else
      render :new
    end
  end

  def edit
    @tender = Unregulated::TenderForm.find(params[:id])
    authorize! :edit, @tender
  end

  def update
    @tender = Unregulated::TenderForm.find(params[:id])
    authorize! :update, @tender

    @tender.attributes = unregulated_params
    @tender.update_other_attributes

    if @tender.save
      redirect_to @tender, notice: t('.notice')
    else
      render :edit
    end
  end

  private

  def unregulated_params
    params.require(:tender)
      .permit(
        :what_valid, :num, :department_id, :user_id, :name, :announce_date, :official_site_num,
        link_tender_files_attributes: [:id, :_destroy, :tender_file_id, :file_type_id, :note],
        lots_attributes: [
          :id, :num, :plan_lot_id, :non_public_reason, :note
        ],
        bidders_attributes: [
          :id, :_destroy, :contractor_id,
          offers_attributes: [
            :id, :_destroy, :status_id, :plan_lot_id, :lot_id, :non_contract_reason,
            contract_attributes: [
              :id, :_destroy, :num, :confirm_date, :non_delivery_reason, :delivery_date_begin, :delivery_date_end
            ],
            offer_specifications_attributes: [
              :id, :plan_specification_id, :final_cost_money, :final_cost_nds_money, :specification_id, :financing_id
            ]
          ]
        ]
      )
  end
end

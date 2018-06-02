class TenderTypeRulesController < ApplicationController
  authorize_resource class: false

  def index
    @tender_types = Dictionary.tender_types.with_rules.distinct
  end

  def edit_all
    @tender_type_list = TenderTypeList.new(rules: Dictionary.tender_types)
  end

  def update_all
    @tender_type_list = TenderTypeList.new(tender_type_list_params)
    @tender_type_list.save_with_rules!
    redirect_to tender_type_rules_path, notice: t('.notice')
  end

  private

  def tender_type_list_params
    params.require(:tender_type_list).permit(rules: [fact_type_ids: []])
  end
end

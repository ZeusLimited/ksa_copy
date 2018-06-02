module TendersHelper
  def link_to_plan_lot(lot)
    link_to content_tag(:span, "#{lot.plan_lot.try(:full_num)} по ГКПЗ #{lot.gkpz_year}", class: "pull-right"),
            plan_lot_path(lot.plan_lot_id),
            target: '_blank'
  end

  def disable_edit_field(html_params)
    html_params.merge!(disabled: true)
  end
end

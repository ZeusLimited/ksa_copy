module ControlPlanLotsHelper
  def control_attributes(user, date)
    return {} if user.nil? || date.nil?
    { class: "bgcolor-pink",
      title: info(user, date)
    }
  end

  def control_notify(control_plan_lot)
    return if control_plan_lot.nil?
    content_tag :div, class: "pull-right alert alert-info" do
      content_tag :strong, info(control_plan_lot.user_fio_short, control_plan_lot.created_at)
    end
  end

  private

  def info(user, date)
    I18n.t(".control_plan_lots_helper.lot_control", user: user, date: date)
  end
end

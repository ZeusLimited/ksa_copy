# frozen_string_literal: true

class PlanLotDecorator < Draper::Decorator
  delegate_all

  def customer_names
    plan_specifications.map(&:customer_name).compact.uniq
  end

  def customer_shortnames
    plan_specifications.map(&:customer_shortname).compact.uniq
  end

  def consumer_shortnames
    plan_specifications.map(&:consumer_shortname).compact.uniq
  end

  def announce_attributes
    css, title = nil
    if last_protocol_version && last_protocol_version == last_agree_version
      if declared? && last_public_lot
        css = { style: last_public_lot.status_stylename_html }
        title = last_public_lot.status_fullname
      elsif last_protocol_version.announce_date < Date.current
        title = I18n.t('.plan_lot_options.delay')
        css = if non_executions.present?
                { class: 'undeclared-with-comment' }
              else
                { class: 'undeclared-without-comment' }
              end
      end
    end
    (css || {}).merge title: title
  end

  def version_class
    not_deleted_version? ? 'version not_deleted_version' : 'version'
  end

  def plan_cost
    @plan_cost ||= plan_specifications.sum('qty * cost')
  end

  def deadline_charge_date
    announce_date - 24
  end

  def rgs?
    department.id == Constants::Departments::RGS
  end

  def etp
    I18n.t('etp', scope: :plan_lot_decorator) if etp?
  end

  def tender_type_name_with_pkfo
    [tender_type_name, preselection_plan_lot&.tender_type_name].compact.join ' '
  end

  def tender_type_fullname_with_pkfo
    [
      tender_type_fullname,
      (I18n.t('type_with_pkfo', scope: :plan_lot_decorator) if preselection_guid),
    ].compact.join ' '
  end
end

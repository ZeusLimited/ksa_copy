module PlanLotsHelper
  def my_simple_form_for(record, url, http_method = nil, options = {}, &block)
    options.merge!(url: url) if url
    options.merge!(method: http_method) if http_method
    simple_form_for(record, options, &block)
  end

  def td_for_plan_lot(plan_lot, &block)
    if plan_lot.status_id
      content_tag(:td, style: plan_lot.status_stylename_html, title: plan_lot.status_fullname, &block)
    else
      content_tag(:td, &block)
    end
  end

  def link_to_popover(plan_lot)
    plne = plan_lot.non_executions.last
    link_to(plan_lot.announce_date,
            '#',
            class: 'popover-plan-lot-announce-date',
            data: { placement: :top,
                    toggle: :popover,
                    title: 'Причина неисполнения срока публикации процедуры',
                    content: render('plan_lot_non_executions/sign', plne: plne).to_str,
                    html: true })
  end

  def link_to_protocol(plan_lot)
    if plan_lot.protocol_id
      link_to "№ #{plan_lot.protocol.num} от #{plan_lot.protocol.date_confirm}", plan_lot.protocol
    else
      "протокол отсутствует"
    end
  end

  def td_for_excel_import(import_lot, attribute)
    if import_lot.errors[attribute].blank?
      content_tag(:td, import_lot.read_attribute(attribute), class: 'success')
    else
      content_tag(:td,
                  content_tag(:div,
                              import_lot.read_attribute(attribute).presence || 'не заполнено',
                              'data-toggle' => 'tooltip',
                              title: import_lot.errors[attribute]),
                  class: 'error')
    end
  end

  def tr_link_for_history_plan_lot(plan_lots, name, value)
    content_tag :tr do
      concat(content_tag(:th, PlanLot.human_attribute_name(name)))
      plan_lots.each do |plan_lot|
        concat(content_tag(:td, link_to(plan_lot.try(value), plan_lot), class: plan_lot.version_class))
      end
    end
  end

  def tr_for_history_plan_lot(plan_lots, name, value)
    content_tag :tr do
      concat(content_tag(:th, PlanLot.human_attribute_name(name)))
      plan_lots.each do |plan_lot|
        concat(content_tag(:td, plan_lot.try(value), class: plan_lot.version_class))
      end
    end
  end

  def tr_for_history_plan_spec(plan_specifications, name, value)
    content_tag :tr do
      concat(content_tag(:th, PlanSpecification.human_attribute_name(name)))
      plan_specifications.each do |plan_specification|
        concat(content_tag(:td, plan_specification.try(value), class: plan_specification.plan_lot.version_class))
      end
    end
  end

  def tr_for_history_plan_spec_amounts(plan_specifications, name, value)
    content_tag :tr do
      concat(content_tag(:th, name))
      plan_specifications.each do |plan_specification|
        mas = []
        plan_specification.plan_spec_amounts.each do |amount|
          mas << "#{amount.year}: #{amount.try(value)}"
        end
        concat(content_tag(:td, mas.join('<br>').html_safe, class: plan_specification.plan_lot.version_class))
      end
    end
  end

  def tr_for_history_plan_spec_address(plan_specifications, name, value)
    content_tag :tr do
      concat(content_tag(:th, name))
      plan_specifications.each do |plan_specification|
        mas = []
        plan_specification.fias_plan_specifications.each do |address|
          mas << address.try(value)
        end
        concat(content_tag(:td, mas.join('<br>').html_safe, class: plan_specification.plan_lot.version_class))
      end
    end
  end

  def gkpz_years_range(end_interval = 2)
    Setting.initial_gkpz_year..Time.now.year + end_interval
  end
end

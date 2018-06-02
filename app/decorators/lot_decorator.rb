class LotDecorator < Draper::Decorator
  delegate_all

  def winners
    @winners ||= win_offers.map(&:bidder_contractor_name_short).uniq.join(', ')
  end

  def consumer_shortnames
    specifications.map(&:consumer_shortname).compact.uniq
  end

  def winner_info
    return unless win_offers.exists?
    win_offers.map do |wo|
      "#{wo.bidder_contractor_name_short}<br><strong>Стоимость: #{p_money wo.final_cost}</strong>"
    end.join('<br><br>')
  end

  def limit_cost
    @limit_cost ||= basic_contracts_cost || winner_cost
  end

  def economy
    return unless specs_cost && limit_cost
    specs_cost - limit_cost
  end

  def link_to_frame_lot
    if frame
      frame_num = frame.plan_lot.try(:full_num)
      frame_url = h.tender_path(frame.tender_id, anchor: h.dom_id(frame))
    else
      frame_num = '(не найден)'
      frame_url = '#'
    end
    h.link_to h.content_tag(:span,
                            "Рамочный конкурс #{frame_num} по ГКПЗ #{lot.gkpz_year}",
                            class: "pull-right"),
              frame_url,
              target: '_blank'
  end

  def contract_termination_info
    return if basic_contracts_termination.empty?
    "Расторгнут. Объем неисполненных обязательств: #{p_money basic_contracts_termination.sum(:unexec_cost)}".html_safe
  end

  def step_increment_cost
    return '____' if step_increment.nil?
    specs_cost_nds * step_increment / 100
  end
end

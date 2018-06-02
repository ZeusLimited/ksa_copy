class BidderDecorator < Draper::Decorator
  delegate_all

  def all_files_to_one
    return
    type = Constants::TenderTypes::TENDERS.include?(tender_type_id) ? 'конкурсной заявки ' : ''
    h.link_to "Получить все файлы #{type}единым архивом", h.all_files_as_one_tender_bidder_path(tender_id, id)
  end

  def link_to_contractor
    h.link_to contractor_name_short, h.contractor_path(contractor_id), h.unfair_contractor_html_attributes(contractor).merge(target: :_blank)
  end

  def wrench
    return unless contractor_orig?
    h.link_icon_title 'icon-wrench', 'Необходима актуализация', h.edit_contractor_path(contractor_id), target: :_blank
  end

  def total_cost_pivot
    offers
      .actuals
      .joins(offer_specifications: :specification)
      .where(num: num)
      .sum('specifications.qty * offer_specifications.final_cost')
  end
end

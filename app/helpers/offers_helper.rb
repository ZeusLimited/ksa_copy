module OffersHelper
  def td_for_offer(offer, cost)
    if offer
      content_tag(:td, style: "#{offer.status_stylename_html}", class: 'right-cell', title: offer.status_name) do
        link_to(p_money(cost), tender_bidder_offer_path(offer.bidder.tender, offer.bidder_id, offer))
      end
    else
      content_tag(:td, '&nbsp;'.html_safe)
    end
  end
end

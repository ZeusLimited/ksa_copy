class OfferDecorator < Draper::Decorator
  include Constants
  delegate_all

  decorates_association :bidder

  def label_status
    lclass =
      case status_id
      when OfferStatuses::RECEIVE then 'label-info'
      when OfferStatuses::REJECT then 'label-important'
      when OfferStatuses::WIN then 'label-success'
      end
    h.content_tag :span, status_name, class: "label #{lclass}"
  end
end

class ReviewLotDecorator < Draper::Decorator
  delegate_all
  decorates_association :lot
end

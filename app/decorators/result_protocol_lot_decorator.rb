class ResultProtocolLotDecorator < Draper::Decorator
  include Constants
  delegate_all
  decorates_association :lot
end

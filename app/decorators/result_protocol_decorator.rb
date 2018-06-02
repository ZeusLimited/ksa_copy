class ResultProtocolDecorator < Draper::Decorator
  include Constants
  delegate_all
  decorates_association :result_protocol_lots
end

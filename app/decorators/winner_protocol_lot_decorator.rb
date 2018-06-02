class WinnerProtocolLotDecorator < Draper::Decorator
  include Constants
  delegate_all
  decorates_association :lot

  def solution
    [solution_type_name, lot.winner_info].compact.join(" ")
  end
end

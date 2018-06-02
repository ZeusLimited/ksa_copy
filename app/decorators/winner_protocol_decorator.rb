class WinnerProtocolDecorator < Draper::Decorator
  delegate_all

  def title
    "Протокол №#{num} от #{confirm_date}"
  end
end

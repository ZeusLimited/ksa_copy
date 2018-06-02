class ProtocolDecorator < Draper::Decorator
  delegate_all

  def date_moved(date)
    I18n.t(
      'activerecord.decorators.protocol.date_moved',
      new_date: date.strftime("%d.%m.%Y"),
      p_date: date_confirm.strftime("%d.%m.%Y"),
      p_num: num
    )
  end
end

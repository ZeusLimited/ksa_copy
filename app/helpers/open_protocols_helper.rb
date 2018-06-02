module OpenProtocolsHelper
  def link_to_b2b
    l_center = link_to 'www.b2b-center.ru', 'http://www.b2b-center.ru', target: '_blank'
    "#{l_center}"
  end

  def class_for_member(protocol_present_member)
    return "hide" if protocol_present_member.hide
    return "clerk" if protocol_present_member.status_id == Constants::Commissioners::CLERK
    nil
  end

  def count_with_description(count, gender, propis, locale = :ru)
    format "%s (%s) %s", count, RuPropisju.propisju(count, gender, locale), I18n.t(propis, count: count)
  end
end

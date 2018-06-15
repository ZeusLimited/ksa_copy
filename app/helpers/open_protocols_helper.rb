module OpenProtocolsHelper
  def link_to_b2b
    l_center = link_to 'www.b2b-center.ru', 'http://www.b2b-center.ru', target: '_blank'
    "#{l_center}"
  end

  def link_to_etp(etp_address_id)
    case etp_address_id
    when Constants::EtpAddress::B2B_ENERGO
      link_to 'www.b2b-center.ru', 'http://www.b2b-center.ru', target: '_blank'
    when Constants::EtpAddress::EETP
      link_to 'rushydro.roseltorg.ru', 'https://rushydro.roseltorg.ru', target: '_blank'
    end
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

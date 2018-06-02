class TenderDecorator < Draper::Decorator
  include Constants
  delegate_all
  SCOPE_LOCAL = [:tender_decorator].freeze

  decorates_association :lots

  def show_template
    if unregulated? && lots.all? { |l| l.status_id == LotStatus::CONTRACT }
      :show_unregulated
    else
      :show
    end
  end

  def link_to_oos
    return "нет" unless oos_num?
    path =
      "http://zakupki.gov.ru" \
      "/223/purchase/public/purchase/info/common-info.html" \
      "?regNumber=#{oos_num}"
    h.link_to oos_num, path, target: '_blank'
  end

  def link_to_etp
    return "нет" unless etp_num?
    case etp_address_id
    when EtpAddress::B2B_ENERGO
      then link_to_b2b
    else
      etp_num
    end
  end

  def link_to_b2b
    suffix = TenderTypes::INTEGRATED_TENDER.include?(tender_type_id) ? '_tender' : ''
    path = "http://www.b2b-center.ru/market/view#{suffix}.html?id=#{etp_num}"
    h.link_to etp_num, path, target: '_blank'
  end

  def oos_b2b_title
    I18n.t('oos_b2b_title',
           num: num,
           link_to_oos: link_to_oos,
           link_to_b2b: link_to_etp,
           scope: SCOPE_LOCAL)
  end

  def title_single_source
    I18n.t('title_single_source',
           num: num,
           date: announce_date,
           link_to_eis: link_to_oos,
           scope: SCOPE_LOCAL)
  end

  def index_row_caption
    type = h.abbr(tender_type_name, tender_type_fullname)
    type += I18n.t('etp', scope: SCOPE_LOCAL) if etp?
    [
      num.strip,
      department_name,
      type,
      I18n.t('gkpz_years', years: lots.map(&:gkpz_year).uniq.join(', '), scope: SCOPE_LOCAL)
    ].join(', ').html_safe
  end

  def integration_status; end

  def subject
    [tender_type_fullname, "на", name].join(' ')
  end

  def etp_name_r
    I18n.t('etp_name_r')
  end

  def contract_period_with_type
    return contract_period if contract_period_type.nil?
    [contract_period, I18n.t(contract_period_type ? 'working_days' : 'calendar_days', scope: SCOPE_LOCAL)].join(' ')
  end

  def docx_template_name
    template_name = template_tender_type
    template_name.concat "_#{template_subject_type}"
    template_name.concat "_b2b" if etp?
    template_name.concat '.docx'
  end

  def template_tender_type
    return "preselection" if preselection?
    return "zc" if zc?
    return "request_offers" if request_offers?
    return "auction" if auction?
    return "tender" if tender?
    "competitive_talk"
  end

  def template_subject_type
    return "materials" if lots.first.subject_type_id == Constants::SubjectType::MATERIALS
    return "work" if work_type?
    "services"
  end

  def offer_guarantie?
    Constants::TenderTypes::OFFER_GUARANTIE.include? tender_type_id
  end

  def alternate_offers?
    Constants::TenderTypes::NO_ALTERNATE_OFFERS.exclude? tender_type_id
  end

  def service_subject_type?
    lots.first.subject_type_id == Constants::SubjectType::SERVICES
  end

  def title_row_class
    return { class: 'info' } if lots.select { |s| s.plan_lot&.control.present? }.blank?
    { class: "bgcolor-pink", title: I18n.t(".control_plan_lots_helper.tender_control") }
  end

  private

  def work_type?
    ProductTypes::WORK_TYPES_LIST.include?(specifications.first.product_type_id)
  end

  def integration_class
    TenderTypes::INTEGRATED_TENDER.include?(tender_type_id) ? 'tender' : 'auction'
  end
end

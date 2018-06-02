class WebServiceController < ApplicationController
  include Constants

  http_basic_authenticate_with(name: 'user', password: 'COwV%|uk') unless Rails.env.development?

  def user_for_paper_trail
    @cache_user_id ||= User.where(login: 'b2b_integrator').first.id
  end

  soap_service

  soap_action 'find_tenders',
              args: {
                year: :integer,
                customer_id: :integer,
                num: :string,
                tender_type_id: :integer
              },
              return: {
                find_tenders: [
                  {
                    plan_lot_guid: :string,
                    oos_num: :integer,
                    lot_id: :integer,
                    is_sme: :string,
                    wp_num: :string,
                    wp_confirm_date: :date,
                    offer_id: :integer,
                    year: :integer,
                    num: :string,
                    name: :string,
                    customer: :string,
                    organizer: :string,
                    is_additional: :boolean,
                    additional_plan_lot_guid: :string,
                    bp_item: :string,
                    financing: :string,
                    is_regulated: :boolean,
                    tender_type: :string,
                    etp: :boolean,
                    winner_name: :string,
                    winner_inn: :string,
                    cost: :decimal,
                    cost_nds: :decimal
                  }
                ]
              }
  def find_tenders
    select_fields = <<-SQL.strip_heredoc
      plan_lots.guid,
      t.oos_num,
      lots.id as lot_id,
      decode(lots.sme_type_id, #{SmeTypes::SME}, 'Только МСП', 'Все') as is_sme,
      wp.num as wp_num,
      wp.confirm_date as wp_confirm_date,
      o.id as offer_id,
      plan_lots.gkpz_year,
      plan_lots.num_tender,
      plan_lots.num_lot,
      plan_lots.lot_name,
      org.name as org_name,
      cust.name as cust_name,
      plan_lots.additional_to,
      main_ps.bp_item,
      fin.name as fin_name,
      plan_lots.tender_type_id,
      tt.name as tt_name,
      plan_lots.etp_address_id,
      ow.shortname || ' ' || c.name as win_name,
      c.inn as win_inn,
      sum_specs.sum_cost,
      sum_specs.sum_cost_nds
    SQL

    plots = plan_lots_with_joins
    plots = plots.select(select_fields)
    plots = plots.joins('left join ownerships ow on ow.id = c.ownership_id')
    plots = plots.where(gkpz_year: params[:year])
    plots = plots.where(root_customer_id: params[:customer_id])
    plots = plots.by_num(params[:num]) if params[:num].present?
    plots = plots.where(tender_type_id: params[:tender_type_id]) if params[:tender_type_id].present?

    result = plots.map do |pl|
      {
        plan_lot_guid: UUIDTools::UUID.parse_raw(pl.guid).to_s,
        oos_num: pl.oos_num,
        lot_id: pl.lot_id,
        is_sme: pl.is_sme,
        wp_num: pl.wp_num,
        wp_confirm_date: date_format(pl.wp_confirm_date),
        offer_id: pl.offer_id,
        year: pl.gkpz_year,
        num: pl.full_num,
        name: pl.lot_name,
        customer: pl.cust_name,
        organizer: pl.org_name,
        is_additional: pl.additional_to.present?,
        additional_plan_lot_guid: pl.additional_to.present? ? UUIDTools::UUID.parse_raw(pl.additional_to).to_s : nil,
        bp_item: pl.bp_item,
        financing: pl.fin_name,
        is_regulated: pl.regulated?,
        tender_type: pl.tt_name,
        etp: pl.etp?,
        winner_name: pl.win_name,
        winner_inn: pl.win_inn,
        cost: pl.sum_cost,
        cost_nds: pl.sum_cost_nds
      }
    end

    render soap: { find_tenders: result }
  end

  soap_action 'get_tenders',
              args: {
                get_tenders_request: [
                  {
                    plan_lot_guid: :string,
                    offer_id: :integer
                  }
                ]
              },
              return: {
                get_tenders: [
                  {
                    plan_lot_guid: :string,
                    offer_id: :integer,
                    year: :integer,
                    num: :string,
                    name: :string,
                    customer: :string,
                    organizer: :string,
                    is_additional: :boolean,
                    financing: :string,
                    tender_type: :string,
                    etp: :boolean,
                    sme_type: :string,
                    winner_name: :string,
                    winner_inn: :string,
                    wp_date: :date,
                    wp_num: :string,
                    oos_num: :long,
                    sub_contractors: {
                      sub_contractor: [
                        name: :string,
                        inn: :string,
                        address: :string,
                        subject: :string,
                        cost_nds: :decimal,
                        confirm_date: :string,
                        num: :string,
                        begin_date: :string,
                        end_date: :string
                      ]
                    }
                  }
                ]
              }
  def get_tenders
    result = result_get_tenders(params[:get_tenders_request]).map do |rt|
      {
        plan_lot_guid: UUIDTools::UUID.parse_raw(rt.guid).to_s,
        offer_id: rt.offer_id,
        year: rt.gkpz_year,
        num: rt.full_num,
        name: rt.lot_name,
        customer: rt.cust_name,
        organizer: rt.org_name,
        is_additional: rt.additional_to.present?,
        financing: rt.fin_name,
        tender_type: rt.tt_name,
        etp: rt.etp?,
        sme_type: rt.sme_name,
        winner_name: rt.win_name,
        winner_inn: rt.win_inn,
        wp_date: date_format(rt.wp_date),
        wp_num: rt.wp_num,
        oos_num: rt.oos_num,
        sub_contractors: { sub_contractor: sub_contractors(rt.contract_id) }
      }
    end

    render soap: { get_tenders: result }
  end

  soap_action 'create_contract',
              args: {
                plan_lot_guid: :string,
                offer_id: :integer,
                num: :string,
                reg_number: :string,
                confirm_date: :date,
                begin_date: :date,
                end_date: :date,
                cost: :double,
                cost_nds: :double,
                additional_plan_lot_guid: :string
              },
              return: {
                success: :boolean,
                error_msg: :string
              }
  def create_contract
    offer = find_offer(params[:plan_lot_guid], params[:offer_id])

    parent_id =
      if params[:additional_plan_lot_guid].present?
        find_offer(params[:additional_plan_lot_guid], nil).contract.try(:id) rescue nil
      end

    contract = offer.contract || offer.build_contract(lot_id: offer.lot_id)
    contract.num                  = params[:num]
    contract.reg_number           = params[:reg_number]
    contract.confirm_date         = params[:confirm_date]
    contract.delivery_date_begin  = params[:begin_date]
    contract.delivery_date_end    = params[:end_date]
    contract.parent_id            = parent_id
    contract.total_cost           = params[:cost]
    contract.total_cost_nds       = params[:cost_nds]

    if contract.new_record?
      contract.delivery_date_begin = contract.confirm_date if contract.confirm_date > contract.delivery_date_begin

      contract.build_contract_specifications
    end

    cs = contract.contract_specifications[0]
    cs.cost = params[:cost]
    cs.cost_nds = params[:cost_nds]

    cs.contract_amounts.build if cs.new_record?

    ca = cs.contract_amounts[0]
    ca.year = offer.lot.gkpz_year
    ca.amount_finance = params[:cost]
    ca.amount_finance_nds = params[:cost_nds]

    fail t('.contract_not_saved', errors: contract.errors.to_hash) unless contract.save

    user = contract.lot.tender.user

    WebServiceMailer.contract_notification(user, contract).deliver_now if user

    render soap: { success: true }
  rescue => e
    render soap: {
      success: false,
      error_msg: e.message
    }
  end

  soap_action 'contractors',
              args: {
                begin_date: :datetime,
                end_date: :datetime,
                id: [:integer]
              },
              return: {
                contractors: [
                  id: :integer,
                  name: :string,
                  fullname: :string,
                  inn: :string,
                  kpp: :string,
                  ogrn: :string,
                  okpo: :string,
                  ownership_shortname: :string,
                  oktmo: :string,
                  legal_addr: :string,
                  form: :string,
                  status: :string
                ]
              }
  def contractors
    contractors = Contractor.all
    contractors = contractors.where('updated_at >= ?', params[:begin_date]) if params[:begin_date].present?
    contractors = contractors.where('updated_at <= ?', params[:end_date]) if params[:end_date].present?
    contractors = if params[:id].present?
      contractors.where(id: params[:id])
    else
      contractors.not_olds
    end

    render soap: { contractors: contractors.as_json(only: [:id, :name, :fullname, :inn, :kpp, :ogrn,
      :okpo, :ownership_shortname, :oktmo, :legal_addr, :form, :status]) }
  end

  soap_action 'departments',
              args: {
                id: [:integer],
                parent_dept_id: [:integer],
                name: :string,
                inn: :string,
                kpp: :string
              },
              return: {
                departments: [
                  id: :integer,
                  parent_dept_id: :integer,
                  name: :string,
                  ownership: :string,
                  inn: :string,
                  kpp: :string
                ]
              }
  def departments
    departments = Department.order(:position)
    departments = departments.where(id: params[:id]) if params[:id].present?
    departments = departments.where(inn: params[:inn]) if params[:inn].present?
    departments = departments.where(kpp: params[:kpp]) if params[:kpp].present?
    departments = departments.where(parent_dept_id: params[:parent_dept_id]) if params[:parent_dept_id].present?
    departments = departments.where("lower(name) like lower(?)", params[:name] + '%') if params[:name].present?

    render soap: { departments: departments.as_json }
  end

  soap_action 'gkpz_lots',
              args: {
                gkpz_year: :integer,
                customer_id: :integer,
                on_date: :datetime,
                gkpz_type: :string,
                announce_date_begin: :date,
                announce_date_end: :date,
                num: [:string],
                guid_hex: [:string]
              },
              return: {
                plan_lot: [
                  id: :integer,
                  guid_hex: :string,
                  additional_to_hex: :string,
                  preselection_guid_hex: :string,
                  gkpz_year: :integer,
                  num_tender: :integer,
                  num_lot: :integer,
                  lot_name: :string,
                  announce_date: :date,
                  subject_type_id: :integer,
                  tender_type_id: :integer,
                  etp_address_id: :integer,
                  point_clause: :string,
                  tender_type_explanations: :string,
                  explanations_doc: :string,
                  department_id: :integer,
                  commission_id: :integer,
                  sme_type_name: :string,
                  order1352_id: :integer,
                  state: :string,
                  status_id: :integer,
                  root_customer_id: :integer,
                  main_direction_id: :integer,
                  regulation_item_id: :integer,
                  created_at: :datetime,
                  updated_at: :datetime,
                  plan_lot_contractors: [contractor_id: :integer],
                  plan_specifications: [
                    id: :integer,
                    guid_hex: :string,
                    plan_lot_id: :integer,
                    num_spec: :integer,
                    name: :string,
                    qty: :integer,
                    cost: :double,
                    cost_nds: :double,
                    unit_code: :string,
                    okdp_code: :string,
                    okved_code: :string,
                    product_type_id: :integer,
                    cost_doc: :string,
                    direction_id: :integer,
                    financing_id: :integer,
                    customer_id: :integer,
                    consumer_id: :integer,
                    monitor_service_id: :integer,
                    delivery_date_begin: :date,
                    delivery_date_end: :date,
                    bp_item: :string,
                    requirements: :string,
                    curator: :string,
                    tech_curator: :string,
                    note: :string,
                    created_at: :datetime,
                    updated_at: :datetime,
                    fias_plan_specifications: [
                      addr_aoid_hex: :string,
                      houseid_hex: :string
                    ],
                    plan_spec_amounts: [
                      year: :integer,
                      amount_mastery: :double,
                      amount_mastery_nds: :double,
                      amount_finance: :double,
                      amount_finance_nds: :double
                    ]
                  ]
                ]
              }
  def gkpz_lots
    plan_lots = if params[:gkpz_type] == 'current'
      PlanLot.current(params[:on_date] || Time.now)
    else
      commission_types = case params[:gkpz_type]
      when 'gkpz' then Constants::CommissionType::SD
      when 'czk' then Constants::CommissionType::MAIN_GROUP
      else nil
      end
      PlanLot.gkpz(params[:on_date] || Date.current, commission_types)
    end
    plan_lots = plan_lots.where(gkpz_year: params[:gkpz_year])
    plan_lots = plan_lots.where(root_customer_id: params[:customer_id])
    plan_lots = plan_lots.where("announce_date >= ?", params[:announce_date_begin]) if params[:announce_date_begin].present?
    plan_lots = plan_lots.where("announce_date <= ?", params[:announce_date_end]) if params[:announce_date_end].present?
    plan_lots = plan_lots.by_numbers(params[:num].join(' ')) if params[:num].present?
    plan_lots = plan_lots.guid_in("plan_lots.guid", params[:guid_hex].map{ |guid| guid.tr('-','') }) if params[:guid_hex].present?

    results = PlanLot.where(id: plan_lots.select(:id)).order(:num_tender, :num_lot)
      .includes(:plan_lot_contractors, :user, :sme_type,
                plan_specifications: [:plan_spec_amounts, :fias_plan_specifications, :okdp, :okved, :unit])
      .references(:plan_lot_contractors, :user, :sme_type,
                  plan_specifications: [:plan_spec_amounts, :fias_plan_specifications, :okdp, :okved, :unit])

    result = results.as_json(
      methods: [:guid_hex, :user_fio_short, :sme_type_name],
      include: [
        :plan_lot_contractors,
        plan_specifications: { methods: [:guid_hex, :okdp_code, :okved_code, :unit_code],
                               except: :guid,
                               include: [:plan_spec_amounts, fias_plan_specifications: { methods: [:addr_aoid_hex, :houseid_hex] }] }])

    render soap: { plan_lot: result }
  end

  soap_action 'find_dictionary',
              args: {
                ref_id: [:integer],
                ref_type: [:string]
              },
              return: {
                dictionary: [
                  ref_id: :integer,
                  ref_type: :string,
                  name: :string,
                  fullname: :string,
                  is_actual: :boolean
                ]
              }
  def find_dictionary
    results = Dictionary.all.order(:ref_type, :position)
    results = results.where(ref_id: params[:ref_id]) if params[:ref_id].present?
    results = results.where(ref_type: params[:ref_type]) if params[:ref_type].present?

    render soap: { dictionary: results.as_json(only: [:ref_id, :ref_type, :name, :fullname, :is_actual]) }
  end

  around_action :write_logs

  private

  def write_logs
    logger.info params.inspect
    log = WebServiceLog.new
    log.soap_action = action_name
    log.ip = request.ip
    log.remote_ip = request.remote_ip
    request.body.rewind
    log.request_body = request.body.read
    yield
    log.response_body = response.body
  rescue => e
    log.response_body = e.message
  ensure
    log.save!
  end

  def find_offer(plan_lot_guid, offer_id)
    offers = Offer.wins.joins(lot: :plan_lot).guid_eq('plan_lots.guid', plan_lot_guid.delete('-'))
    offers.where(id: offer_id) if offer_id

    case offers.count
    when 0 then fail t('.offer_not_found')
    when 1 then offers.first
    else fail t('.offer_more_one')
    end
  end

  def date_format(d)
    d ? d.strftime('%F') : nil
  end

  def plan_lots_with_joins
    PlanLot
      .last_agreement
      .last_lots
      .joins_main_spec
      .joins_sum_specs
      .joins('INNER JOIN dictionaries tt ON plan_lots.tender_type_id = tt.ref_id')
      .joins('INNER JOIN dictionaries fin ON main_ps.financing_id = fin.ref_id')
      .joins('INNER JOIN departments org ON plan_lots.department_id = org.id')
      .joins('INNER JOIN departments cust ON plan_lots.root_customer_id = cust.id')
      .joins('LEFT JOIN tenders t ON t.id = lots.tender_id')
      .joins('LEFT JOIN winner_protocols wp ON wp.id = lots.winner_protocol_id')
      .joins("LEFT JOIN offers o ON o.lot_id = lots.id AND o.version = 0 AND o.status_id = #{OfferStatuses::WIN}")
      .joins('LEFT JOIN bidders b ON b.id = o.bidder_id')
      .joins('LEFT JOIN contractors c ON c.id = b.contractor_id')
      .where('lots.status_id IN (?) OR plan_lots.tender_type_id = ?',
             LotStatus::HELD,
             TenderTypes::ONLY_SOURCE)
  end

  def sub_contractors(contract_id)
    return [] unless contract_id
    select_fields = <<-SQL.strip_heredoc
      o.shortname || ' ' || c.name as name,
      c.inn as inn,
      c.legal_addr,
      sum_sub_specs.sum_cost,
      sum_sub_specs.sum_cost_nds,
      sub_contractors.name as subject,
      sub_contractors.confirm_date,
      sub_contractors.num,
      sub_contractors.begin_date,
      sub_contractors.end_date
    SQL

    sub_contractors = SubContractor
                      .joins_sum_sub_specs
                      .joins('INNER JOIN contractors c ON c.id = sub_contractors.contractor_id')
                      .joins('left join ownerships o on c.ownership_id = o.id')
                      .where(contract_id: contract_id)
                      .select(select_fields)

    sub_contractors.map do |sub|
      {
        name: sub.name,
        inn: sub.inn,
        address: sub.legal_addr,
        subject: sub.subject,
        cost_nds: sub.sum_cost_nds,
        confirm_date: date_format(sub.confirm_date),
        num: sub.num,
        begin_date: date_format(sub.begin_date),
        end_date: date_format(sub.end_date)
      }
    end
  end

  def result_get_tenders(request_tenders)
    select_fields = <<-SQL.strip_heredoc
      plan_lots.guid,
      o.id as offer_id,
      plan_lots.gkpz_year,
      num_tender,
      num_lot,
      lot_name,
      org.name as org_name,
      cust.name as cust_name,
      plan_lots.additional_to,
      main_ps.bp_item,
      fin.name as fin_name,
      plan_lots.tender_type_id,
      tt.name as tt_name,
      plan_lots.etp_address_id,
      sme.name as sme_name,
      ow.shortname || ' ' || c.name as win_name,
      c.inn as win_inn,
      t.oos_num,
      wp.confirm_date as wp_date,
      wp.num as wp_num,
      contracts.id as contract_id,
      sum_specs.sum_cost,
      sum_specs.sum_cost_nds
    SQL

    plots = plan_lots_with_joins
    plots = plots.joins('LEFT JOIN tenders t ON lots.tender_id = t.id')
    plots = plots.joins('LEFT JOIN ownerships ow on ow.id = c.ownership_id')
    plots = plots.joins('LEFT JOIN winner_protocols wp ON lots.winner_protocol_id = wp.id')
    plots = plots.joins('LEFT JOIN contracts ON contracts.offer_id = o.id')
    plots = plots.joins('LEFT JOIN dictionaries sme ON lots.sme_type_id = sme.ref_id')
    plots = plots.select(select_fields)

    filters = request_tenders.map do |rt|
      filter_by_guid_and_offer(rt[:plan_lot_guid], rt[:offer_id])
    end

    plots.where(filters.join(' OR '))
  end

  def filter_by_guid_and_offer(guid, offer_id)
    if offer_id
      format '(%s AND o.id = %s)', my_guid_eq('plan_lots.guid', guid), offer_id
    else
      my_guid_eq('plan_lots.guid', guid)
    end
  end

  def my_guid_eq(field, guid)
    if ActiveRecord::Base.oracle_adapter?
      format '%s = hextoraw(%s)', field, ActiveRecord::Base.connection.quote(guid.tr('-', ''))
    else
      format '%s = %s', field, ActiveRecord::Base.connection.quote(guid)
    end
  end
end

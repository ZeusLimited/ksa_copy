# frozen_string_literal: true

class TenderFilter
  include ActiveModel::Model
  include Constants

  attr_accessor(
    :years,
    :customers,
    :organizers,
    :monitor_services,
    :announce_date_begin,
    :announce_date_end,
    :directions,
    :subject_types,
    :statuses,
    :tender_types,
    :etp_addresses,
    :search_by_name,
    :search_by_num,
    :search_by_gkpz_num,
    :by_winner,
    :control_lots,
    :search_by_contract_nums,
    :wp_solutions,
    :consumers,
    :etp_num,
    :wp_date_begin,
    :wp_date_end,
    :contract_date_begin,
    :contract_date_end,
    :bidders,
    :start_cost,
    :end_cost,
    :start_tender_cost,
    :end_tender_cost,
    :sme_types,
    :regulation_items,
    :order1352,
    :bp_states,
    :plan_lot_guids,
    :okdp,
    :okved,
    :users,
    :current_user,
    # downgrade compatibility
    :gkpz_year,
    :customer,
  )

  REQUIRED_ASSOCIATIONS = [
    :department,
    :tender_type,
    lots: [
      :status, :winner_protocol_lots,
      specifications: :customer,
      plan_lot: [:control, :plan_specifications],
      win_offers: [offer_specifications: :specification, bidder: [contractor: :ownership]]
    ]
  ].freeze

  FROM = <<-SQL.freeze
    tenders
    inner join lots l on (tenders.id = l.tender_id)
    inner join specifications s on (s.lot_id = l.id)
  SQL

  INDEX = <<-SQL.freeze
    #{FROM}
    left join offers o on o.lot_id = l.id and o.version = 0 and o.status_id = #{OfferStatuses::WIN}
    left join bidders b on b.tender_id = tenders.id and o.bidder_id = b.id
    left join contractors con on con.id = b.contractor_id
    left join ownerships ow on con.ownership_id = ow.id
    left join contracts c on (c.lot_id = l.id and c.offer_id = o.id and c.type_id = #{ContractTypes::BASIC})
    left join winner_protocol_lots wpl on (wpl.lot_id = l.id and wpl.winner_protocol_id = l.winner_protocol_id)
    left join winner_protocols wp on wp.id = l.winner_protocol_id and wp.id = wpl.winner_protocol_id
    left join plan_lots pl on pl.id = l.plan_lot_id
    left join plan_specifications ps on ps.plan_lot_id = pl.id and ps.id = s.plan_specification_id
  SQL

  EXCEL = <<-SQL.freeze
    #{INDEX}
    inner join dictionaries fact_ttype on tenders.tender_type_id = fact_ttype.ref_id
    inner join departments org on org.id = tenders.department_id
    left join ownerships owo on owo.id = org.ownership_id
    inner join dictionaries status on (status.ref_id = l.status_id)
    inner join departments cust on l.root_customer_id = cust.id
    left join ownerships owc on owc.id = cust.ownership_id
    left join open_protocols op on tenders.id = op.tender_id
    left join review_protocols rp on rp.id = l.review_protocol_id
    left join rebid_protocols rb on rb.id = l.rebid_protocol_id
    left join dictionaries sl on sl.ref_id = wpl.solution_type_id
    left join offer_specifications os on os.specification_id = s.id and os.offer_id = o.id
    left join contract_specifications cs on cs.specification_id = s.id and cs.contract_id = c.id
    left join
      (select * from
        (select tpl.*, row_number() over (partition by tpl.guid order by tpl.status_id desc, tp.date_confirm desc) rn
          from plan_lots tpl
          inner join protocols tp on tp.id = tpl.protocol_id
          where tpl.status_id in (#{Constants::PlanLotStatus::AGREEMENT_LIST.join(', ')})) sub
         where rn = 1) gkpz_pl on (pl.guid = gkpz_pl.guid)
    left join dictionaries gkpz_ttype on gkpz_pl.tender_type_id = gkpz_ttype.ref_id
    left join dictionaries subj_t on (subj_t.ref_id = l.subject_type_id)
    left join directions lot_dir on (lot_dir.id = l.main_direction_id)
    left join fias_plan_specifications fs on (fs.plan_specification_id = ps.id)
    left join fias on fias.id = fs.fias_id
    left join okved on (okved.id = ps.okved_id)
    left join okdp on (okdp.id = ps.okdp_id)
    left join
      (select plan_lot_id,
                    string_agg(distinct fias.okato, '; ') as fias_okato,
                    string_agg(distinct fias.name, '; ') as fias_name
        from fias
            inner join fias_plan_specifications fs on fias.id = fs.fias_id
            inner join plan_specifications ps on ps.id = fs.plan_specification_id
        group by ps.plan_lot_id
    ) sub on sub.plan_lot_id = pl.id
    left join
      (select o.lot_id as lot_id, count(o.bidder_id) as cnt_offers
       from offers o
       group by o.lot_id
      ) t_cnt_offers on (t_cnt_offers.lot_id = l.id)
  SQL

  SQL_LOT_COST = <<-SQL.freeze
    (select sum(ss.qty * ss.cost) from specifications ss where ss.lot_id = l.id)
  SQL

  SQL_TENDER_COST = <<-SQL.freeze
    (select sum(ss.qty * ss.cost) from specifications ss, lots ll where ss.lot_id = ll.id and ll.tender_id = tenders.id)
  SQL

  def additional_search?
    [wp_solutions, consumers, etp_num, wp_date_begin, wp_date_end, contract_date_begin, contract_date_end, bidders,
     start_cost, end_cost, start_tender_cost, end_tender_cost, sme_types, regulation_items, order1352, okdp, okved,
     subject_types, search_by_contract_nums, etp_addresses, monitor_services, announce_date_begin, announce_date_end,
     users, bp_states].any?(&:present?)
  end

  def sub_query?
    [
      years, subject_types, statuses, search_by_name, search_by_gkpz_num, customers, monitor_services, by_winner,
      directions, search_by_name, search_by_gkpz_num, control_lots, search_by_contract_nums, wp_solutions,
      contract_date_begin, contract_date_end, wp_date_begin, wp_date_end, regulation_items, sme_types, consumers,
      okdp, okved, order1352, bidders, start_cost, end_cost, bp_states, plan_lot_guids
    ].any?(&:present?)
  end

  def lots_count
    return unless @tenders
    @lots_count ||=
      mine(Tender.from(FROM)).where(id: @tenders.select("tenders.id")).select("count(distinct l.id) as cnt").take.cnt
  end

  def filters(tenders)
    tenders = mine tenders

    # downgrade compatibility
    self.years ||= gkpz_year if gkpz_year.present?
    self.customers ||= customer if customer.present?
    # -----------------------

    tenders = tenders.where('tenders.announce_date >= ?', announce_date_begin&.to_date) if announce_date_begin.present?
    tenders = tenders.where('tenders.announce_date <= ?', Date.parse(announce_date_end)) if announce_date_end.present?
    tenders = tenders.where('wp.confirm_date >= ?', Date.parse(wp_date_begin)) if wp_date_begin.present?
    tenders = tenders.where('wp.confirm_date <= ?', Date.parse(wp_date_end)) if wp_date_end.present?
    tenders = tenders.where('c.confirm_date >= ?', Date.parse(contract_date_begin)) if contract_date_begin.present?
    tenders = tenders.where('c.confirm_date <= ?', Date.parse(contract_date_end)) if contract_date_end.present?

    tenders = tenders.where(tender_type_id: tender_types.map(&:to_i)) if tender_types.present?
    tenders = tenders.where(etp_address_id: etp_addresses.map(&:to_i)) if etp_addresses.present?
    tenders = tenders.where(user_id: users.split(',')) if users.present?
    tenders = tenders.where("#{SQL_TENDER_COST} >= ?", start_tender_cost.to_f) if start_tender_cost.present?
    tenders = tenders.where("#{SQL_TENDER_COST} <= ?", end_tender_cost.to_f) if end_tender_cost.present?
    tenders = tenders.where("#{SQL_LOT_COST} >= ?", start_cost.to_f) if start_cost.present?
    tenders = tenders.where("#{SQL_LOT_COST} <= ?", end_cost.to_f) if end_cost.present?

    tenders = tenders.where('l.gkpz_year in (?)', years.map(&:to_i)) if years.present?
    tenders = tenders.where('l.status_id in (?)', statuses.map(&:to_i)) if statuses.present?
    tenders = tenders.where('s.direction_id in (?)', directions.map(&:to_i)) if directions.present?
    tenders = tenders.where("pl.regulation_item_id in (?)", regulation_items.map(&:to_i)) if regulation_items.present?
    tenders = tenders.where("l.sme_type_id in (?)", sme_types) if sme_types.present?
    tenders = tenders.where("s.consumer_id in (?)", consumers.map(&:to_i)) if consumers.present?
    tenders = tenders.where("ps.okdp_id in (?)", okdp.split(',').map(&:to_i)) if okdp.present?
    tenders = tenders.where("ps.okved_id in (?)", okved.split(',').map(&:to_i)) if okved.present?
    tenders = tenders.where("pl.order1352_id in (?)", order1352.map(&:to_i)) if order1352.present?
    tenders = tenders.where("l.plan_lot_guid in (?)", plan_lot_guids) if plan_lot_guids.present?
    tenders = tenders.where("ps.bp_state_id in (?)", bp_states) if bp_states.present?
    tenders = tenders.where('l.subject_type_id in (?)', subject_types.map(&:to_i)) if subject_types.present?
    tenders = tenders.where('s.monitor_service_id in (?)', monitor_services.map(&:to_i)) if monitor_services.present?
    tenders = tenders.where(Tender.filter_by_search_name(search_by_name)) if search_by_name.present?
    tenders = tenders.where(Tender.filter_by_control_lots) if control_lots.present? && control_lots.to_b

    if search_by_num.present?
      tenders = tenders.where ApplicationRecord.multi_value_filter("(lower(tenders.num) || '.' like lower('%s'))", search_by_num)
    end

    if etp_num.present?
      tenders = tenders.where ApplicationRecord.multi_value_filter("(lower(tenders.etp_num) || '.' like lower('%s'))", etp_num)
    end

    if bidders.present?
      tenders = tenders.where(
        "b.contractor_id in (?)", Contractor.where(guid: Contractor.where(id: bidders.split(',')).select(:guid))
                                             .select(:id)
      )
    end

    if search_by_gkpz_num.present?
      tenders = tenders.where ApplicationRecord.multi_value_filter("(pl.num_tender || '.' || pl.num_lot like '%s')", search_by_gkpz_num)
    end

    if search_by_contract_nums.present?
      tenders = tenders.where ApplicationRecord.multi_value_filter("(lower(c.num) like lower('%s'))", search_by_contract_nums)
    end

    if by_winner.present?
      contractor_fields = %w(con.inn con.kpp con.ogrn ow.shortname con.name con.fullname).join(" || ' ' || ")
      tenders = tenders.where(
        format("replace(lower(%s),'ё', 'е') like replace(lower(?), 'ё', 'е')", contractor_fields), "%#{by_winner}%"
      )
    end

    if organizers.present?
      tenders = tenders.where(department_id: Department.organizers_child_ids(organizers.map(&:to_i)))
    end

    if customers.present?
      tenders = tenders.where("s.customer_id in (?)", Department.customers_child_ids(customers.map(&:to_i)))
    end

    if wp_solutions.present?
      tenders = tenders.where('wpl.solution_type_id in (?)', wp_solutions.map(&:to_i))
    end

    @tenders = tenders
    @tenders
  end

  def search
    filters Tender.from(INDEX)
    Tender.includes(*REQUIRED_ASSOCIATIONS)
          .references(*REQUIRED_ASSOCIATIONS)
          .where(id: @tenders.select("tenders.id"))
          .order(:num)
  end

  def mine(tenders)
    return tenders if current_user.root_dept_id.blank?
    tenders = tenders.where(
      "(s.customer_id in (?) or tenders.department_id in (?))",
      Department.subtree_ids_for(current_user.root_dept_id),
      Department.subtree_ids_for(current_user.root_dept_id)
    )
    tenders
  end

  def for_excell
    tenders = mine(Tender.from(EXCEL)).where(id: filters(Tender.from(INDEX)).select("tenders.id"))
    tenders = tenders.select <<-SQL
      count(*) over (partition by l.id) row_span,
      row_number() over (partition by l.id order by con.ownership_id, con.name) as row_number,
      l.gkpz_year,
      case when owc.shortname is null then cust.name else owc.shortname || ' ' || cust.name end as customer_name,
      fias_okato,
      fias_name,
      case when owo.shortname is null then org.name else owo.shortname || ' ' || org.name end as organizer_name,
      pl.num_tender || '.' || pl.num_lot as gkpz_num,
      tenders.num || '.' || l.num as tender_num,
      lot_dir.name as dir_name,
      subj_t.name as subj_name,
      string_agg(distinct okved.code, '; ') as okved_code,
      string_agg(distinct okdp.code, '; ') as okdp_code,
      l.name as lot_name,
      sum(ps.qty * ps.cost) as plan_cost,
      sum(ps.qty * ps.cost_nds) as plan_cost_nds,
      sum(s.qty * s.cost) as fact_cost,
      sum(s.qty * s.cost_nds) as fact_cost_nds,
      case when gkpz_pl.id is not null
           then gkpz_ttype.name || decode(gkpz_pl.etp_address_id, #{EtpAddress::NOT_ETP}, '', null, '', ' ЭТП')
           else fact_ttype.name || decode(tenders.etp_address_id,#{EtpAddress::NOT_ETP}, '', ' ЭТП')
           end as gkpz_ttype_name,
      fact_ttype.name || decode(tenders.etp_address_id, 12001, '', ' ЭТП') as fact_ttype_name,
       decode(wpl.solution_type_id, #{WinnerProtocolSolutionTypes::SINGLE_SOURCE}, 'ЕУ', null) as fact_ei,
      gkpz_pl.announce_date as plan_announce_date,
      tenders.announce_date,
      op.open_date,
      rp.confirm_date as review_protocol_date,
      rb.confirm_date as rebid_protocol_date,
      wp.confirm_date as winner_protocol_date,
      wp.num as winner_protocol_num,
      sl.name as solution_type_name,
      t_cnt_offers.cnt_offers as cnt_offers,
      coalesce(ow.shortname, '') || ' ' || con.name as winner_name,
      case when con.is_sme then 'да' else 'нет' end as winner_is_sme,
      con.inn as winner_inn,
      con.legal_addr as winner_addr,
      sum(s.qty * os.final_cost) as winner_cost,
      sum(s.qty * os.final_cost_nds) as winner_cost_nds,
      c.confirm_date as contract_date,
      c.num as contract_num,
      sum(s.qty * cs.cost) as contract_cost,
      sum(s.qty * cs.cost_nds) as contract_cost_nds,
      to_char(l.boss_note) as boss_note
    SQL

    tenders = tenders.group <<-SQL
      l.id, l.gkpz_year, gkpz_pl.announce_date, owc.shortname, cust.name, owo.shortname, org.name, pl.num_tender, pl.num_lot,
      tenders.num, l.num, l.name, lot_dir.name, subj_t.name, gkpz_ttype.name, fact_ttype.name, con.ownership_id,
      gkpz_pl.id, t_cnt_offers.cnt_offers, fias_okato, fias_name,
      decode(tenders.etp_address_id, #{EtpAddress::NOT_ETP}, '', ' ЭТП'),
      decode(gkpz_pl.etp_address_id, #{EtpAddress::NOT_ETP}, '', null, '', ' ЭТП'),
      decode(wpl.solution_type_id, #{WinnerProtocolSolutionTypes::SINGLE_SOURCE}, 'ЕУ', null),
      tenders.announce_date, op.open_date, rp.confirm_date, rb.confirm_date, wp.confirm_date, wp.num, sl.name,
      ow.shortname, con.name, con.is_sme, con.inn, con.legal_addr, c.confirm_date, c.num, to_char(l.boss_note)
    SQL

    tenders.order('tenders.num, l.num, l.id, con.ownership_id, con.name')
  end

  COLUMNS = {
    c1: { type: :integer, style: :td, width: 5 },
    c2: { type: :integer, style: :td_right, value: ->(r) { r['gkpz_year'] }, width: 15 },
    c3: { type: :string, style: :td, value: ->(r) { r['customer_name'].strip }, width: 25 },
    c3_0: { type: :string, style: :td, value: ->(r) { r['fias_okato'].strip }, width: 25 },
    c3_1: { type: :string, style: :td, value: ->(r) { r['fias_name'].strip }, width: 25 },
    c4: { type: :string, style: :td, value: ->(r) { r['organizer_name'].strip }, width: 25 },
    c5: { type: :string, style: :td_right, value: ->(r) { r['gkpz_num'] }, width: 15 },
    c6: { type: :string, style: :td_right, value: ->(r) { r['tender_num'] }, width: 15 },
    c6_0: { type: :string, style: :td, value: ->(r) { r['dir_name'].strip }, width: 15 },
    c6_1: { type: :string, style: :td, value: ->(r) { r['subj_name'].strip }, width: 15 },
    c6_2: { type: :string, style: :td, value: ->(r) { r['okved_code'].strip }, width: 15 },
    c6_3: { type: :string, style: :td, value: ->(r) { r['okdp_code'].strip }, width: 15 },
    c7: { type: :string, style: :td, value: ->(r) { r['lot_name'].try(:strip) }, width: 50 },
    c8: { type: :float, style: :td_money, value: ->(r) { r['plan_cost'] }, sum: true, width: 20 },
    c8_1: { type: :float, style: :td_money, value: ->(r) { r['plan_cost_nds'] }, sum: true, width: 20 },
    c9: { type: :float, style: :td_money, value: ->(r) { r['fact_cost'] }, sum: true, width: 20 },
    c9_1: { type: :float, style: :td_money, value: ->(r) { r['fact_cost_nds'] }, sum: true, width: 20 },
    c10: { type: :string, style: :td, value: ->(r) { r['gkpz_ttype_name'] }, width: 15 },
    c10_0: { type: :string, style: :td, value: ->(r) { r['fact_ttype_name'] }, width: 15 },
    c10_1: { type: :string, style: :td, value: ->(r) { r['fact_ei'] }, width: 15 },
    c11: { type: :date, style: :td_date, value: ->(r) { r['plan_announce_date'].try(:to_date) }, width: 15 },
    c11_0: { type: :date, style: :td_date, value: ->(r) { r['announce_date'].try(:to_date) }, width: 15 },
    c12: {
      type: :date, style: :td_date, value: ->(r) { r['open_date'].try(:getlocal, Time.zone.utc_offset).try(:to_date) },
      width: 15
    },
    c13: { type: :date, style: :td_date, value: ->(r) { r['review_protocol_date'].try(:to_date) }, width: 15 },
    c14: { type: :date, style: :td_date, value: ->(r) { r['rebid_protocol_date'].try(:to_date) }, width: 15 },
    c15: { type: :date, style: :td_date, value: ->(r) { r['winner_protocol_date'].try(:to_date) }, width: 15 },
    c16: { type: :string, style: :td_right, value: ->(r) { r['winner_protocol_num'] }, width: 15 },
    c17: { type: :string, style: :td_right, value: ->(r) { r['solution_type_name'] }, width: 15 },
    c17_0: { type: :string, style: :td_right, value: ->(r) { r['cnt_offers'] }, width: 15 },
    c18: { type: :string, style: :td, no_merge: true, value: ->(r) { r['winner_name'] }, width: 30 },
    c18_0: { type: :string, style: :td, no_merge: true, value: ->(r) { r['winner_is_sme'] }, width: 5 },
    c18_1: { type: :string, style: :td, no_merge: true, value: ->(r) { r['winner_inn'] }, width: 30 },
    c18_2: { type: :string, style: :td, no_merge: true, value: ->(r) { r['winner_addr'] }, width: 50 },
    c19: {
      type: :float, style: :td_money, no_merge: true, value: ->(r) { r['winner_cost'] }, sum: true, width: 20
    },
    c19_1: {
      type: :float, style: :td_money, no_merge: true, value: ->(r) { r['winner_cost_nds'] }, sum: true, width: 20
    },
    c20: {
      type: :date, style: :td_date, no_merge: true, value: ->(r) { r['contract_date'].try(:to_date) }, width: 15
    },
    c21: { type: :string, style: :td_right, no_merge: true, value: ->(r) { r['contract_num'] }, width: 15 },
    c22: { type: :float, style: :td_money, no_merge: true, value: ->(r) { r['contract_cost'] }, sum: true, width: 20 },
    c23: {
      type: :float, style: :td_money, no_merge: true, value: ->(r) { r['contract_cost_nds'] }, sum: true, width: 20
    },
    c24: { type: :string, style: :td, value: ->(r) { r['boss_note'] }, width: 15 }
  }.freeze

  COLUMNS.each_pair do |ckey, cval|
    define_singleton_method(ckey) { |r| cval[:value].call(r) }
  end
end

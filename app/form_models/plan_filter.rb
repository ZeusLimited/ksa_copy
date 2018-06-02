# frozen_string_literal: true

class PlanFilter
  include ActiveModel::Model

  def initialize(attributes={})
    super
    current_user.insert_all_plan_lots(filter) if selected_lots == '1'
  end

  DECLARED_VALS = { 'Опубликованные' => 'declared', 'Неопубликованные' => 'undeclared' }.freeze

  SQL_LOT_COST = <<-SQL
    (select sum(pps.qty * pps.cost) from plan_specifications pps where pps.plan_lot_id = plan_lots.id)
  SQL

  REQUIRED_ASSOCIATIONS = [
    :department,
    :status,
    :tender_type,
    :control,
    :etp_address,
    :protocol,
    :non_executions,
    public_lots: :status,
    preselection: :tender_type,
    plan_specifications: :customer,
  ].freeze

  attr_accessor(
    :years,
    :state,
    :gkpz_state,
    :gkpz_on_date_begin,
    :gkpz_on_date_end,
    :customers,
    :organizers,
    :monitor_services,
    :date_begin,
    :date_end,
    :directions,
    :subject_types,
    :tender_types,
    :statuses,
    :etp_addresses,
    :declared,
    :name,
    :num,
    :control_lots,
    :start_cost,
    :end_cost,
    :consumers,
    :sme_types,
    :order1352,
    :okdp,
    :okved,
    :bp_states,
    :bidders,
    :regulation_items,
    :current_user,
    :selected_lots,
  )

  validates :gkpz_on_date_begin, :gkpz_on_date_end, presence: true, if: proc { |pf| pf.gkpz_state == "on_date" }

  def additional_search?
    [date_begin, date_end, start_cost, end_cost, organizers, monitor_services, consumers, etp_addresses,
     subject_types, sme_types, okdp, okved, bidders, order1352, declared, control_lots, state, regulation_items,
     gkpz_on_date_begin, gkpz_on_date_end, bp_states].any?(&:present?)
  end

  def filter
    plots = PlanLot.user_scope(current_user).left_outer_joins(:preselection)
    plots = plots.where(gkpz_year: years) if years.present?
    plots = plots.where(state: PlanLot.states[state]) if state.present?
    plots = if gkpz_state == "on_date"
              plots.on_date(gkpz_on_date_begin.to_date, gkpz_on_date_end.to_date)
            else
              plots.actuals
            end
    specs_values = {}
    specs_values[:customer_id] = Department.customers_child_ids(customers) if customers.present?
    specs_values[:monitor_service_id] = monitor_services if monitor_services.present?
    specs_values[:direction_id] = directions if directions.present?
    specs_values[:consumer_id] = consumers if consumers.present?
    specs_values[:okdp_id] = okdp.split(',') if okdp.present?
    specs_values[:okved_id] = okved.split(',') if okved.present?

    plots = plots.by_spec_field_in(specs_values) unless specs_values.empty?
    plots = plots.where(department_id: Department.organizers_child_ids(organizers)) if organizers.present?
    plots = plots.where('plan_lots.announce_date >= ?', date_begin.to_date) if date_begin.present?
    plots = plots.where('plan_lots.announce_date <= ?', date_end.to_date) if date_end.present?
    plots = plots.where(subject_type_id: subject_types) if subject_types.present?
    plots = plots.where(tender_type_id: tender_types) if tender_types.present?
    plots = plots.where(status_id: statuses) if statuses.present?
    plots = plots.where(regulation_item_id: regulation_items) if regulation_items.present?
    plots = plots.where(etp_address_id: etp_addresses) if etp_addresses.present?
    plots = plots.where("#{SQL_LOT_COST} >= ?", start_cost.to_f) if start_cost.present?
    plots = plots.where("#{SQL_LOT_COST} <= ?", end_cost.to_f) if end_cost.present?
    plots = plots.declared if declared == 'declared'
    plots = plots.undeclared if declared == 'undeclared'
    plots = plots.by_name_words(name) if name.present?
    plots = plots.by_numbers(num) if num.present?
    plots = plots.send(control_lots) if control_lots.present? && %w(0 1).exclude?(control_lots)
    plots = plots.by_spec_field_in(bp_state_id: bp_states) if bp_states.present?
    plots = plots.where(sme_type_id: sme_types) if sme_types.present?
    plots = plots.where(order1352_id: order1352.split(',')) if order1352.present?
    plots = plots.where(
      id: PlanLotContractor.where(
        contractor_id: Contractor.where(guid: Contractor.where(id: bidders.split(',')).select(:guid)).select(:id),
      ).select(:plan_lot_id),
    ) if bidders.present?

    plots
  end

  def search
    PlanLot.includes(*REQUIRED_ASSOCIATIONS)
           .references(*REQUIRED_ASSOCIATIONS)
           .where(id: filter.select("plan_lots.id"))
           .order(:num_tender, :num_lot)
  end

  def search_excel
    filter
      .joins(EXCEL_JOINS)
      .order("plan_lots.num_tender, plan_lots.num_lot")
      .select <<-SQL
        rt.name as root_customer_name,
        cons.name as consumer_name,
        ps.name,
        plan_lots.num_tender || '.' || plan_lots.num_lot as lot_number,
        lot_status.fullname as lot_status_fullname,
        fin.name as source_finance,
        ps.cost * ps.qty as price,
        ps.cost_nds * ps.qty as price_nds,
        plan_lots.announce_date,
        tend_type.fullname as tend_type_name,
        plan_lots.etp_address_id,
        org.name as org_name,
        comm_type.name comm_type_name,
        mon.name as dep_kurator,
        ps.delivery_date_begin,
        EXTRACT(YEAR FROM ps.delivery_date_begin) as delivery_date_begin_year,
        ps.delivery_date_end,
        EXTRACT(YEAR FROM ps.delivery_date_end) as delivery_date_end_year,
        pc.plan_contractors,
        ps.bp_item,
        sme.name as sme_type,
        ord.fullname as order1352,
        psa1.amount_mastery as amount_mastery1,
        psa1.amount_mastery_nds as amount_mastery_nds1,
        psa2.amount_mastery as amount_mastery2,
        psa2.amount_mastery_nds as amount_mastery_nds2,
        psa3.amount_mastery as amount_mastery3,
        psa3.amount_mastery_nds as amount_mastery_nds3,
        psa4.amount_mastery as amount_mastery4,
        psa4.amount_mastery_nds as amount_mastery_nds4,
        psa5.amount_mastery as amount_mastery5,
        psa5.amount_mastery_nds as amount_mastery_nds5,
        ps.note,
        ps.curator,
        ps.tech_curator,
        st.name as status_name,
        plne.reason as non_execute,
        plan_lots.charge_date as charge_date,
        (plan_lots.announce_date - 24) as deadline_charge_date,
        bpst.num || ' - ' || bpst.name as bp_state,
        dir.name as dir_name,
        okdp.code || ' (' || okdp.name || ')' as okdp,
        okved.code  || ' (' || okdp.name || ')' as okved
      SQL
  end

  def search_excel_lot
    filter
      .joins(EXCEL_JOINS)
      .order("plan_lots.num_tender, plan_lots.num_lot")
      .select(<<-SQL
        rt.name as root_customer_name,
        (#{ActiveRecord::Base.concatinate('cons.name', "'; '", 'ps.id')}) as consumer_name,
        plan_lots.lot_name as name,
        plan_lots.num_tender || '.' || plan_lots.num_lot as lot_number,
        lot_status.fullname as lot_status_fullname,
        --
        (#{ActiveRecord::Base.concatinate('fin.name', "'; '", 'ps.id')}) as source_finance,
        sum(ps.cost * ps.qty) as price,
        sum(ps.cost_nds * ps.qty) as price_nds,
        plan_lots.announce_date,
        plan_lots.charge_date as charge_date,
        (plan_lots.announce_date - 24) as deadline_charge_date,
        tend_type.fullname as tend_type_name,
        plan_lots.etp_address_id,
        org.name as org_name,
        comm_type.name comm_type_name,
        (#{ActiveRecord::Base.concatinate('mon.name', "'; '", 'ps.id')}) as dep_kurator,
        min(ps.delivery_date_begin) as delivery_date_begin,
        min(EXTRACT(YEAR FROM ps.delivery_date_begin)) as delivery_date_begin_year,
        max(ps.delivery_date_end) as delivery_date_end,
        max(EXTRACT(YEAR FROM ps.delivery_date_end)) as delivery_date_end_year,
        pc.plan_contractors,
        (#{ActiveRecord::Base.concatinate('ps.bp_item', "'; '", 'ps.id')}) as bp_item,
        sme.name as sme_type,
        ord.fullname as order1352,
        sum(psa1.amount_mastery) as amount_mastery1,
        sum(psa1.amount_mastery_nds) as amount_mastery_nds1,
        sum(psa2.amount_mastery) as amount_mastery2,
        sum(psa2.amount_mastery_nds) as amount_mastery_nds2,
        sum(psa3.amount_mastery) as amount_mastery3,
        sum(psa3.amount_mastery_nds) as amount_mastery_nds3,
        sum(psa4.amount_mastery) as amount_mastery4,
        sum(psa4.amount_mastery_nds) as amount_mastery_nds4,
        sum(psa5.amount_mastery) as amount_mastery5,
        sum(psa5.amount_mastery_nds) as amount_mastery_nds5,
        --
        (#{ActiveRecord::Base.concatinate('ps.note', "'; '", 'ps.id')}) as note,
        --
        (#{ActiveRecord::Base.concatinate('ps.curator', "'; '", 'ps.id')}) as curator,
        --
        (#{ActiveRecord::Base.concatinate('ps.tech_curator', "'; '", 'ps.id')}) as tech_curator,
        st.name as status_name,
        to_char(plne.reason) as non_execute,
        bpst.num || ' - ' || bpst.name as bp_state,
        (#{ActiveRecord::Base.concatinate('dir.name', "'; '", 'ps.id')}) as dir_name,
        (#{ActiveRecord::Base.concatinate("okdp.code || ' (' || okdp.name || ')'", "'; '", 'ps.id')}) as okdp,
        (#{ActiveRecord::Base.concatinate("okved.code  || ' (' || okdp.name || ')'", "'; '", 'ps.id')}) as okved,
        fias_okato,
        fias_name
      SQL
      ).group <<-SQL
        rt.name, plan_lots.lot_name, plan_lots.num_tender, lot_status.fullname, plan_lots.num_lot, plan_lots.announce_date, plan_lots.charge_date,
        tend_type.fullname, plan_lots.etp_address_id, org.name, comm_type.name, pc.plan_contractors, sme.name,
        ord.fullname, st.name, to_char(plne.reason), bpst.num, bpst.name, fias_okato, fias_name
      SQL
  end

  EXCEL_JOINS = <<-SQL.freeze
    inner join plan_specifications ps on ps.plan_lot_id = plan_lots.id
    left join dictionaries tend_type on tend_type.ref_id = plan_lots.tender_type_id
    left join departments org on org.id = plan_lots.department_id
    left join commissions comm on comm.id = plan_lots.commission_id
    left join dictionaries comm_type on comm_type.ref_id = comm.commission_type_id
    left join dictionaries fin on fin.ref_id = ps.financing_id
    left join dictionaries st on st.ref_id = plan_lots.status_id
    left join departments mon on mon.id = ps.monitor_service_id
    left join departments rt on rt.id = plan_lots.root_customer_id
    left join departments cons on ps.consumer_id = cons.id
    left join plan_spec_amounts psa1 on (ps.id = psa1.plan_specification_id and psa1.year = plan_lots.gkpz_year)
    left join plan_spec_amounts psa2 on (ps.id = psa2.plan_specification_id and psa2.year = plan_lots.gkpz_year+1)
    left join plan_spec_amounts psa3 on (ps.id = psa3.plan_specification_id and psa3.year = plan_lots.gkpz_year+2)
    left join plan_spec_amounts psa4 on (ps.id = psa4.plan_specification_id and psa4.year = plan_lots.gkpz_year+3)
    left join plan_spec_amounts psa5 on (ps.id = psa5.plan_specification_id and psa5.year = plan_lots.gkpz_year+4)
    left join dictionaries sme on (sme.ref_id = plan_lots.sme_type_id)
    left join dictionaries ord on (ord.ref_id = plan_lots.order1352_id)
    left join plan_lots psl on psl.guid = plan_lots.preselection_guid and psl.version = 0
    left join bp_states bpst on bpst.id = ps.bp_state_id
    left join directions dir on dir.id = ps.direction_id
    left join okdp on okdp.id = ps.okdp_id
    left join okved on okved.id = ps.okved_id
    left join
      (select plan_lot_id,
                    string_agg(distinct fias.okato, '; ') as fias_okato,
                    string_agg(distinct fias.name, '; ') as fias_name
        from fias
            inner join fias_plan_specifications fs on fias.id = fs.fias_id
            inner join plan_specifications ps on ps.id = fs.plan_specification_id
        group by ps.plan_lot_id
    ) sub on sub.plan_lot_id = plan_lots.id
    left join
      (select * from
          (
            select
            plan_lot_guid, reason, row_number() over(partition by plan_lot_guid order by id desc) as rn
            from plan_lot_non_executions
          ) sub
        where rn = 1
      ) plne on plan_lots.guid = plne.plan_lot_guid
    left join
      (select
        plc.plan_lot_id,
        (#{ActiveRecord::Base.concatinate("coalesce(ow.shortname, '') || ' ' || c.name", "'; '", 'plc.contractor_id')})
          as plan_contractors
      from plan_lot_contractors plc
      inner join contractors c on c.id = plc.contractor_id
      left join ownerships ow on c.ownership_id = ow.id
      group by plc.plan_lot_id) pc on pc.plan_lot_id = plan_lots.id
    left join
          (select l1.plan_lot_guid, l1.status_id,
           row_number() over (partition by l1.plan_lot_guid order by t1.announce_date) as rn
            from tenders t1
            inner join lots l1 on t1.id = l1.tender_id and l1.plan_lot_guid is not null
        ) last_public on (last_public.plan_lot_guid = plan_lots.guid and last_public.rn = 1)
	  left join dictionaries as lot_status on lot_status.ref_id = last_public.status_id
  SQL
end

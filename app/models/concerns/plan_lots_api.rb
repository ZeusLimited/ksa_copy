module PlanLotsApi
  extend ActiveSupport::Concern
  include Constants

  included do
    scope :last_agreement, ->(at_date = nil) { from_agreement(at_date).where('plan_lots.ag_rn = 1') }
    scope :last_protocol, ->(at_date = nil) { from_protocols(at_date).where('plan_lots.ag_rn = 1') }
    scope :gkpz, (lambda do |at_date = Time.now, commission_types = nil|
      from_gkpz(at_date, commission_types).where('plan_lots.ag_rn = 1')
    end)
    scope :current, -> (at_date = Time.now) { from_plan(at_date).where('plan_lots.rn = 1') }
    scope :last_lots, (lambda do
      joins_lots
        .where("lots.lot_rn = 1 OR (lots.lot_rn IS NULL and plan_lots.tender_type_id = #{TenderTypes::ONLY_SOURCE})")
    end)
  end

  class_methods do
    def from_agreement(at_date = nil)
      filter = at_date ? ' and ' + sanitize_sql(['date_confirm <= ?', at_date.to_date]) : nil
      from <<-SQL.strip_heredoc
        (
          SELECT
            tpl.*,
            row_number() OVER (PARTITION BY tpl.guid ORDER BY tp.date_confirm DESC) AS ag_rn
          FROM plan_lots tpl
          INNER JOIN protocols tp ON tp.id = tpl.protocol_id #{filter}
          WHERE tpl.status_id IN (#{PlanLotStatus::AGREEMENT_LIST.join(', ')})
        ) plan_lots
      SQL
    end

    def from_plan(at_date)
      from <<-SQL.strip_heredoc
        (
          SELECT * from (
            SELECT pl.*,
            row_number() OVER (PARTITION BY pl.guid ORDER BY pl.created_at DESC) rn
            from plan_lots pl where #{sanitize_sql(['created_at <= ?', at_date])}
          ) pl2
        ) plan_lots
      SQL
    end

    def from_protocols(at_date = nil)
      filter = at_date ? ' and ' + sanitize_sql(['date_confirm <= ?', at_date]) : nil
      from <<-SQL.strip_heredoc
        (
          SELECT
            tpl.*,
            row_number() OVER (PARTITION BY tpl.guid ORDER BY tp.date_confirm DESC) AS ag_rn
          FROM plan_lots tpl
          INNER JOIN protocols tp ON tp.id = tpl.protocol_id #{filter}
        ) plan_lots
      SQL
    end

    def from_gkpz(at_date = Time.now, commission_types = nil)
      filter = commission_types ? ' and ' + sanitize_sql(['commission_type_id in (?)', commission_types]) : nil
      from <<-SQL.strip_heredoc
        (
          SELECT
            tpl.*,
            row_number() OVER (PARTITION BY tpl.guid ORDER BY tpl.status_id, tp.date_confirm DESC) AS ag_rn
          FROM plan_lots tpl
          INNER JOIN protocols tp ON tp.id = tpl.protocol_id and #{sanitize_sql(['date_confirm <= ?', at_date])}
          INNER JOIN commissions tc on tc.id = tp.commission_id #{filter}
        ) plan_lots
      SQL
    end

    def in_limit?(collection)
      sql = <<-SQL.strip_heredoc
        select
          1
        from plan_lots pl
          inner join
          (select id from
            (select tpl.id, row_number() over (partition by tpl.guid order by tp.date_confirm desc) rn
              from plan_lots tpl
                inner join protocols tp on tp.id = tpl.protocol_id
              where (tpl.gkpz_year, tpl.root_customer_id, tpl.num_tender) in (#{collection})
             ) sub
             where rn = 1) gkpz_pl on (pl.id = gkpz_pl.id)
          left join
          (select * from
            (select tpl.*, row_number() over (partition by tpl.guid order by tp.date_confirm desc) rn
              from plan_lots tpl
                inner join protocols tp on tp.id = tpl.protocol_id
              where tpl.preselection_guid is not null
             ) sub
             where rn = 1) ppl on (pl.guid = ppl.preselection_guid)
          inner join plan_specifications ps on (ps.plan_lot_id = nvl(ppl.id, pl.id))
          inner join departments d on d.id = pl.root_customer_id
        Where pl.status_id in (#{PlanLotStatus::AGREEMENT_LIST.join(', ')})
        Group By d.tender_cost_limit, pl.gkpz_year, pl.num_tender, pl.num_tender
        Having sum(ps.qty * ps.cost) > d.tender_cost_limit
      SQL
      connection.select_all(sql).count == 0
    end

    def joins_lots
      joins <<-SQL.strip_heredoc
        LEFT JOIN (
          SELECT
            tpl.guid as plan_guid,
            tl.*,
            row_number() OVER (PARTITION BY tpl.guid ORDER BY tpl.version) AS lot_rn
          FROM plan_lots tpl
          INNER JOIN lots tl ON tl.plan_lot_id = tpl.id
          WHERE tl.next_id is null
        ) lots on plan_lots.guid = lots.plan_guid
      SQL
    end

    def joins_main_spec
      joins <<-SQL.strip_heredoc
        INNER JOIN (
          SELECT
            tps.*,
            row_number() OVER (PARTITION BY tps.plan_lot_id ORDER BY tps.cost * tps.qty DESC) AS ag_ps_rn
          FROM plan_lots tpl
          INNER JOIN plan_specifications tps ON tps.plan_lot_id = tpl.id
          WHERE tps.direction_id = tpl.main_direction_id
        ) main_ps ON main_ps.plan_lot_id = plan_lots.id AND ag_ps_rn = 1
      SQL
    end

    def joins_sum_specs
      joins <<-SQL.strip_heredoc
        INNER JOIN (
          SELECT
            tps.plan_lot_id,
            sum(tps.qty * tps.cost) AS sum_cost,
            sum(tps.qty * tps.cost_nds) AS sum_cost_nds
          FROM plan_specifications tps
          GROUP BY tps.plan_lot_id
        ) sum_specs ON sum_specs.plan_lot_id = plan_lots.id
      SQL
    end
  end
end

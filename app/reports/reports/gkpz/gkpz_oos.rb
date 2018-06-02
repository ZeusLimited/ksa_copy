module Reports
  module Gkpz
    class GkpzOos
      include ActiveModel::Model
      include ActiveRecord::Sanitization::ClassMethods
      include Constants

      attr_accessor :table_name
      attr_accessor :gkpz_year, :date_gkpz_on_state, :customer, :organizer, :gkpz_type,
                    :status, :address_etp, :tender_type, :direction, :subject_type

      def connection
        ActiveRecord::Base.connection
      end

      GKPZ_TYPES = {
        'Вce (План+Внеплан)' => 'all_gkpz_unplanned',
        'План' => 'gkpz',
        'Внеплановые закупки' => 'unplanned',
        'Текущие (не утвержденные)' => 'current'
      }

      def init(current_user)
        filters = []
        filters << sanitize_sql(["EXTRACT(YEAR FROM pl.announce_date) = %s", gkpz_year])

        if subject_type.present?
          filters << sanitize_sql(["pl.subject_type_id in (%s)", subject_type.join(',')])
        end

        if address_etp.present?
          filters << sanitize_sql(["pl.etp_address_id in (%s)", address_etp.join(',')])
        end

        sub_sql = "select id from departments start with id in (%s) connect by prior id = parent_dept_id"
        if current_user.root_dept_id
          filters << sanitize_sql(["ps.customer_id in (#{sub_sql})", current_user.root_dept_id])
        end

        if customer.present?
          filters << sanitize_sql(["ps.customer_id in (#{sub_sql})", customer.join(',')])
        end

        if organizer.present?
          filters << sanitize_sql(["pl.department_id in (#{sub_sql})", organizer.join(',')])
        end

        if tender_type.present?
          filters << sanitize_sql(["pl.tender_type_id in (%s)", tender_type.join(',')])
        end

        if direction.present?
          filters << sanitize_sql(["ps.direction_id in (%s)", direction.join(',')])
        end

        filters << sanitize_sql(["pl.status_id in (%s)", status.join(',')]) if status.present?

        protocol_filters = []
        protocol_filters << sanitize_sql(["p1.date_confirm <= ?", date_gkpz_on_state.to_date])

        case gkpz_type
        when 'all_gkpz_unplanned'
          # nothing
        when 'gkpz'
          protocol_filters << "c1.commission_type_id = #{CommissionType::SD}"
        when 'unplanned'
          filters << "not exists (select 'x' from plan_lots l where l.status_id = #{PlanLotStatus::CONFIRM_SD} " \
                     "and l.guid = pl.guid)"
        when 'current'
          filters << 'pl.version = 0'
        end

        join_protocols = <<-SQL
          inner join protocols p on (pl.protocol_id = p.id)
          inner join commissions c on (p.commission_id = c.id)
          inner join (
            select l.guid, max(p1.date_confirm) as date_confirm from plan_lots l
            inner join protocols p1 on (p1.id = l.protocol_id)
            inner join commissions c1 on (p1.commission_id = c1.id) where #{protocol_filters.join(' and ')}
            Group By l.guid) vi on (vi.guid = pl.guid and p.date_confirm = vi.date_confirm)
        SQL

        join_protocols = '' if gkpz_type == 'current'

        @sql = <<-SQL
          select
            span, rn, decode(span,1,0,rn,1,0) is_merge,
            decode(rn,1,id,null) as id,
            decode(rn,1,okved_code,null) as okved_code,
            decode(rn,1,okdp_code,null) as okdp_code,
            decode(rn,1,lot_name,null) as lot_name,
            decode(rn,1,requirements,null) as requirements,
            decode(rn,1,unit_code,null) as unit_code,
            decode(rn,1,unit_name,null) as unit_name,
            decode(rn,1,qty,null) as qty,
            fias_okato,
            fias_name,
            decode(rn,1,cost, null) cost,
            decode(rn,1,cost_nds,null) as cost_nds,
            decode(rn,1,announce_date,null) as announce_date,
            decode(rn,1,delivery_date_end,null) as delivery_date_end,
            decode(rn,1,type_name,null) as type_name,
            decode(rn,1,is_elform,null) as is_elform
          from (
            SELECT
            count(*) over (partition by ps.id) span,
            row_number() over (
              partition by ps.id order by lpad(num_tender, 6, '0'), num_lot, ps.num_spec,
              fa.fullname, fh.housenum, fh.buildnum, fh.strucnum
            ) as rn,
            ps.id,
            okved.code as okved_code,
            okdp.code as okdp_code,
            ps.name as lot_name,
            ps.requirements,
            units.code as unit_code,
            units.name as unit_name,
            ps.qty,
            fa.fullname || ' ' || fh.housenum ||
              (case when fh.buildnum is not null then ' корпус ' || fh.buildnum else '' end) ||
              (case when fh.strucnum is not null then ' строение ' || fh.strucnum else '' end) as fias_name,
            nvl(fh.okato, fa.okato) as fias_okato,
            ps.qty*ps.cost as cost,
            ps.qty*ps.cost_nds as cost_nds,
            pl.announce_date,
            ps.delivery_date_end,
            rtype.name as type_name,
             decode(pl.etp_address_id,#{EtpAddress::NOT_ETP},'нет','да') as is_elform
            FROM plan_specifications ps
              inner join plan_lots pl on pl.id = ps.plan_lot_id
              left join units on (units.id = ps.unit_id)
              left join okved on (okved.id = ps.okved_id)
              left join okdp on (okdp.id = ps.okdp_id)
              left join dictionaries rtype on (rtype.ref_id = pl.tender_type_id)
              left join fias_plan_specifications fs on (fs.plan_specification_id = ps.id)
              left join fias_addrs fa on (fs.addr_aoid = fa.aoid)
              left join fias_houses fh on (fs.houseid = fh.houseid)
              #{join_protocols}
            WHERE #{filters.join(' and ')} and additional_parameters
            ORDER BY lpad(num_tender, 6, '0'), num_lot, ps.num_spec, ps.id,
              fa.fullname, fh.housenum, fh.buildnum, fh.strucnum
          )
        SQL
      end

      def get_gkpz_rows(quarter)
        filter = "pl.announce_date #{between_quarter(quarter, gkpz_year)}"
        sql = @sql.sub('additional_parameters', filter)
        connection.select_all(sql).to_ary
      end

      private

      def between_quarter(quarter, year)
        day_month = case quarter
                    when 1 then ["01.01", "31.03"]
                    when 2 then ["01.04", "30.06"]
                    when 3 then ["01.07", "30.09"]
                    when 4 then ["01.10", "31.12"]
                    end
        "between to_date('#{day_month[0]}.#{year}','dd.mm.yyyy') and to_date('#{day_month[1]}.#{year}','dd.mm.yyyy')"
      end
    end
  end
end

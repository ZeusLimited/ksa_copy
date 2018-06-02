module Reports
  module Other
    class Rosstat < Reports::Base
      attr_accessor :col, :line, :detail

      def default_params
        @default_params ||= {
          begin_date: date_begin.to_date,
          end_date: date_end.to_date,
          customer: customer.to_i
        }.with_indifferent_access
      end

      def sql_result(line)
        self.send("line#{line}_sql_rows")
      end

      # types = [:date, :time, :float, :integer, :string, :boolean]

      COLUMNS = {
        c1: { type: :string, style: :td, width: 50 },
        c2: { type: :string, style: :td, width: 10 },
        c3: { type: :integer, style: :td, value: ->(r) { r['num_all'] }, width: 15 },
        c4: { type: :integer, style: :td, value: ->(r) { r['num_ok'] }, width: 15 },
        c5: { type: :integer, style: :td, value: ->(r) { r['num_zk'] }, width: 15 },
        c6: { type: :integer, style: :td, value: ->(r) { r['num_ok_etp'] }, width: 15 },
        c7: { type: :integer, style: :td, value: ->(r) { r['num_oa'] }, width: 15 },
        c8: { type: :integer, style: :td, value: ->(r) { r['num_za'] }, width: 15 },
        c9: { type: :integer, style: :td, value: ->(r) { r['num_oa_etp'] }, width: 15 },
        c10: { type: :integer, style: :td, value: ->(r) { r['num_ei'] }, width: 15 },
        c11: { type: :integer, style: :td, value: ->(r) { r['num_other_o'] }, width: 15 },
        c12: { type: :integer, style: :td, value: ->(r) { r['num_other_z'] }, width: 15 },
        c13: { type: :integer, style: :td, value: ->(r) { r['num_other_etp'] }, width: 15 }
      }

      MONEY_COLUMNS = {
        c1: { type: :string, style: :td, width: 50 },
        c2: { type: :string, style: :td, width: 10 },
        c3: { type: :float, style: :td_money, value: ->(r) { to_thousand(r['cost_all']) }, width: 15 },
        c4: { type: :float, style: :td_money, value: ->(r) { to_thousand(r['cost_ok']) }, width: 15 },
        c5: { type: :float, style: :td_money, value: ->(r) { to_thousand(r['cost_zk']) }, width: 15 },
        c6: { type: :float, style: :td_money, value: ->(r) { to_thousand(r['cost_ok_etp']) }, width: 15 },
        c7: { type: :float, style: :td_money, value: ->(r) { to_thousand(r['cost_oa']) }, width: 15 },
        c8: { type: :float, style: :td_money, value: ->(r) { to_thousand(r['cost_za']) }, width: 15 },
        c9: { type: :float, style: :td_money, value: ->(r) { to_thousand(r['cost_oa_etp']) }, width: 15 },
        c10: { type: :float, style: :td_money, value: ->(r) { to_thousand(r['cost_ei']) }, width: 15 },
        c11: { type: :float, style: :td_money, value: ->(r) { to_thousand(r['cost_other_o']) }, width: 15 },
        c12: { type: :float, style: :td_money, value: ->(r) { to_thousand(r['cost_other_z']) }, width: 15 },
        c13: { type: :float, style: :td_money, value: ->(r) { to_thousand(r['cost_other_etp']) }, width: 15 }
      }

      COLUMNS.each_pair do |ckey, cval|
        define_singleton_method(ckey) { |r| cval[:value].call(r) }
      end

      MONEY_COLUMNS.each_pair do |ckey, cval|
        define_singleton_method(ckey) { |r| cval[:value].call(r) }
      end

      private

      def line101_row(as_name, type, etp = nil)
        add_etp = etp ? 'and t.etp_address_id != 12001' : 'and t.etp_address_id = 12001' unless etp.nil?
        "coalesce(sum(case when t.tender_type_id in (#{type}) #{add_etp} then 1 else 0 end), 0) as #{as_name}"
      end

      def line105_row(as_name, type, etp = nil)
        add_etp = etp ? 'and coalesce(bt.etp_address_id, t.etp_address_id) != 12001' : 'and coalesce(bt.etp_address_id, t.etp_address_id) = 12001' unless etp.nil?
        "coalesce(sum(case when coalesce(bt.tender_type_id, t.tender_type_id) in (#{type}) #{add_etp} then 1 else 0 end), 0) as #{as_name}"
      end

      def line301_row(as_name, type, etp = nil)
        add_etp = etp ? 'and t.etp_address_id != 12001' : 'and t.etp_address_id = 12001' unless etp.nil?
        "(case when t.tender_type_id in (#{type}) #{add_etp} then sum(s.qty * s.cost_nds) else 0 end) as #{as_name}"
      end

      def line301_ei_row(as_name, type)
        "(case when t.tender_type_id in (#{type}) then sum(s.qty * cs.cost_nds) else 0 end) as #{as_name}"
      end

      def line304_row(as_name, type, etp = nil)
        add_etp = etp ? 'and t.etp_address_id != 12001' : 'and t.etp_address_id = 12001' unless etp.nil?
        "(case when t.tender_type_id in (#{type}) #{add_etp} then sum(s.qty * cs.cost_nds) else 0 end) as #{as_name}"
      end

      def line306_row(as_name, type, etp = nil)
        add_etp = etp ? 'and etp_address_id != 12001' : 'and etp_address_id = 12001' unless etp.nil?
        "coalesce(sum(case when tender_type_id in (#{type}) #{add_etp} then cost_nds else 0 end), 0) as #{as_name}"
      end

      def line307_row(as_name, type, etp = nil)
        add_etp = etp ? 'and t.etp_address_id != 12001' : 'and t.etp_address_id = 12001' unless etp.nil?
        "coalesce(sum(case when t.tender_type_id in (#{type}) #{add_etp} then unexec_cost else 0 end), 0) as #{as_name}"
      end

      def line308_row(as_name, type, etp = nil)
        add_etp = etp ? 'and t.etp_address_id != 12001' : 'and t.etp_address_id = 12001' unless etp.nil?
        "(case when t.tender_type_id in (#{type}) #{add_etp} then sum(s.qty * scs.cost_nds) else 0 end) as #{as_name}"
      end

      def additional_filter(col, coalesce = false)
        return '' if col == "3"
        type = if coalesce
                 "coalesce(bt.tender_type_id, t.tender_type_id)"
               else
                 "t.tender_type_id"
               end
        etp_address = if coalesce
                        "coalesce(bt.etp_address_id, t.etp_address_id)"
                      else
                        "t.etp_address_id"
                      end
        case col.to_i
        when 4 then
          etp = false
          types = Constants::TenderTypes::OK.join(',')
        when 5 then
          etp = nil
          types = Constants::TenderTypes::ZK.join(',')
        when 6 then
          etp = true
          types = Constants::TenderTypes::OK.join(',')
        when 7 then
          etp = false
          types = Constants::TenderTypes::OA
        when 8 then
          etp = nil
          types = Constants::TenderTypes::ZA
        when 9 then
          etp = true
          types = Constants::TenderTypes::OA
        when 10 then
          etp = nil
          types = Constants::TenderTypes::ROSSTAT_EI.join(',')
        when 11 then
          etp = false
          types = Constants::TenderTypes::ROSSTAT_OTHER_OPEN.join(',')
        when 12 then
          etp = nil
          types = Constants::TenderTypes::ROSSTAT_OTHER_CLOSE.join(',')
        when 13 then
          etp = true
          types = Constants::TenderTypes::ROSSTAT_OTHER_OPEN.join(',')
        end

        add_etp = etp ? "and #{etp_address} != 12001" : "and #{etp_address} = 12001" unless etp.nil?
        " and #{type} in (#{types}) #{add_etp}"
      end

      def detail_select
        <<-SQL
          pl.num_tender || (case when l.frame_id is not null then '.' || t.num else '' end) || '.' ||
            nvl2(l.frame_id, l.num, pl.num_lot) as num,
          l.name,
          case when t.tender_type_id in (#{Constants::TenderTypes::FRAMES.join(', ')}) then 0 else
          (
            select sum(gkpz_ps.qty * gkpz_ps.cost_nds)
            from plan_specifications gkpz_ps
            where gkpz_ps.plan_lot_id = gkpz_pl.id
          ) end as gkpz_cost,
          (
            select sum(s.qty * s.cost_nds)
            from specifications s
            where s.lot_id = l.id) as plan_cost,
          wp.confirm_date as protocol_confirm_date,
          (
            select sum(s.qty * os.final_cost_nds)
            from offers o
              inner join offer_specifications os on (os.offer_id = o.id)
              inner join specifications s on (s.id = os.specification_id)
            where o.version = 0 and o.lot_id = l.id and o.status_id = 26004) as fact_cost,
          c.confirm_date as contract_date,
          (
            select sum(specifications.qty * contract_specifications.cost_nds)
            from contract_specifications
              inner join specifications on (specifications.id = contract_specifications.specification_id)
              Where contract_specifications.contract_id = c.id
          ) as contract_cost,
          l.frame_id
        SQL
      end

      def detail_join
        <<-SQL
          left join
          (select * from
            (select tpl.*, row_number() over (partition by tpl.guid order by tpl.status_id desc, tp.date_confirm desc) rn
              from plan_lots tpl
              inner join protocols tp on tp.id = tpl.protocol_id and tp.date_confirm <= :end_date
              where tpl.status_id in (#{Constants::PlanLotStatus::AGREEMENT_LIST.join(', ')})) sub
             where rn = 1) gkpz_pl on (pl.guid = gkpz_pl.guid)
        SQL
      end
    end
  end
end

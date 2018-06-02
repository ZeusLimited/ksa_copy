module Reports
  module Reglament
    class MounthlyAnalysis < Reports::Base
      attr_accessor :line, :type, :detail

      def structure
        @structure ||= YAML.load(ERB.new(File.read("#{structures}/monthly_analysis.yml")).result(binding))
      end

      def row_title(rownum, param)
        I18n.t("#{self.class.to_s.underscore}.table_rows.row#{rownum}.#{param}")
      end

      def month
        I18n.l date_end.to_date, format: '%B'
      end

      def state_mounth
        date_end.to_date.end_of_month + 10.days
      end

      def customer_name
        return if customers.to_a.size != 1
        Department.find(customers[0]).fullname
      end

      def gkpz_year
        return "201_" if gkpz_years.to_a.size != 1
        gkpz_years[0]
      end

      def default_params
        @default_params ||= {
          begin_date: date_begin.to_date,
          end_date: date_end.to_date
        }.with_indifferent_access
      end

      def gkpz_row(filters)
        gkpz_sql_rows.select do |r|
          filters.all? { |k, v| Array(v).include?(r[k.to_s]) }
        end.inject({}) do |h1, h2|
          h1.merge(h2) do |k, o, n|
            o + (n || 0) unless k.to_s == 'direction_id'
          end
        end
      end

      def unplan_row(filters, zzc = { zzc: 0 })
        unplan_sql_rows.select do |r|
          filters.all? { |k, v| Array(v).include?(r[k.to_s]) }
        end.inject({}) do |h1, h2|
          h1.merge(h2) do |k, o, n|
            o + (n || 0) unless k.to_s == 'direction_id'
          end
        end
      end

      def all_tenders_row(filters)
        all_tenders_sql_rows.select do |r|
          filters.all? { |k, v| Array(v).include?(r[k.to_s]) }
        end.inject({}) do |h1, h2|
          h1.merge(h2) do |k, o, n|
            o + (n || 0) if %(cnt_all cost_nds_all final_cost_nds_all cnt cost_nds final_cost_nds).include?(k.to_s)
          end
        end
      end

      def gkpz_ps_row(filters)
        r1 = gkpz_row(filters)
        r2 = all_tenders_row(filters)

        return { 'cnt_all' => 0, 'cost_nds_all' => 0 } if (r1['cnt_all'] || 0) == 0

        {
          'cnt_all' => r2['cnt_all'] / r1['cnt_all'].to_f,
          'cost_nds_all' => r2['cost_nds_all'] / r1['cost_nds_all'] * 1_000
        }
      end

      def all_in_work_row(filters)
        result = [unpublic_row, cancelled_row, public_tenders_row, open_tenders_row, fail_tenders_row]

        { 'cnt_all' => result.map { |h| h['cnt_all'] || 0 }.sum,
          'cost_nds_all' => result.map { |h| h['cost_nds_all'] || 0 }.sum,
          'cnt' => result.map { |h| h['cnt'] || 0 }.sum,
          'cost_nds' => result.map { |h| h['cost_nds'] || 0 }.sum
        }
      end

      def unpublic_row(filters = nil)
        unpublic_sql_rows.first
      end

      def cancelled_row(filters = nil)
        cancelled_sql_rows.first
      end

      def public_tenders_row(filters = nil)
        public_tenders_sql_rows.first
      end

      def open_tenders_row(filters = nil)
        open_tenders_sql_rows.first
      end

      def null_values_row(filters)
        { 'cnt_all' => 0, 'cost_nds_all' => 0, 'cnt' => 0, 'cost_nds' => 0 }
      end

      def fail_tenders_row(filters = nil)
        fail_tenders_sql_rows.first
      end

      def dictionaries_row(filters)
        r1 = old_tenders_row(filters.select { |k, v| k == 'etp_address_id' } )
        r2 = all_tenders_row(filters.select { |k, v| k == 'is_profitable' })

        { 'cnt_all' => (r1['cnt_all'] || 0) + (r2['cnt_all'] || 0),
          'cost_nds_all' => (r1['cost_nds_all'] || 0) + (r2['cost_nds_all'] || 0),
          'final_cost_nds_all' => (r1['final_cost_nds_all'] || 0) + (r2['final_cost_nds_all'] || 0),
          'cnt' => (r1['cnt'] || 0) + (r2['cnt'] || 0),
          'cost_nds' => (r1['cost_nds'] || 0) + (r2['cost_nds'] || 0),
          'final_cost_nds' => (r1['final_cost_nds'] || 0) + (r2['final_cost_nds'] || 0)
        }
      end

      def old_tenders_row(filters)
        old_tenders_sql_rows.select do |r|
          filters.all? { |k, v| Array(v).include?(r[k.to_s]) }
        end.inject({}) do |h1, h2|
          h1.merge(h2) do |k, o, n|
            o + (n || 0) if %(cnt_all cost_nds_all final_cost_nds_all cnt cost_nds final_cost_nds).include?(k.to_s)
          end
        end
      end

      def profit_tenders_row(filters)
        profit_tenders_sql_rows.first
      end

      def details
        line_structure = structure.select { |t| t['num'] == line }.first
        self.send(line_structure['sql'] + "_sql_rows").select do |r|
          line_structure['filters'].all? { |k, v| Array(v).include?(r[k.to_s]) }
        end
      end

      COLUMNS = {
        c1: { type: :string, style: :td, width: 05 },
        c2: { type: :string, style: :td, width: 25 },
        c3: { type: :integer, style: :td, value: ->(r) { r['cnt_all'] }, width: 10 },
        c4: { type: :float, style: :td_money, value: ->(r) { to_thousand(r['cost_nds_all']) }, width: 15 },
        c5: { type: :float, style: :td_money, value: ->(r) { to_thousand(r['final_cost_nds_all']) || 'x' }, width: 15 },
        c6: { type: :integer, style: :td, value: ->(r) { r['cnt'] || 'x' }, width: 10 },
        c7: { type: :float, style: :td_money, value: ->(r) { to_thousand(r['cost_nds']) || 'x' }, width: 15 },
        c8: { type: :float, style: :td_money, value: ->(r) { to_thousand(r['final_cost_nds']) || 'x' }, width: 15 }
      }
    end
  end
end
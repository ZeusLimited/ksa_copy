module Reports
  module Pui
    class CurrentOperation < Reports::Base
      def default_params
        @default_params ||= {
          begin_date: date_begin.to_date,
          end_date: date_end.to_date,
          gkpz_year: gkpz_year.to_i
        }.with_indifferent_access
      end

      def result_row(filter)
        plan_row(filter).merge(fact_row(filter))
      end

      def plan_row(filter)
        plan_sql_rows.select do |row|
          filter.all? { |k, v| Array(v).include?(row[k.to_s]) }
        end.inject({}) do |h1, h2|
          h1.merge(h2) do |k, o, n|
            (o || 0.0) + (n || 0.0) if %(direction_id tender_type_id).exclude?(k)
          end
        end
      end

      def fact_row(filter)
        fact_sql_rows.select do |row|
          filter.all? { |k, v| Array(v).include?(row[k.to_s]) }
        end.inject({}) do |h1, h2|
          h1.merge(h2) do |k, o, n|
            (o || 0.0) + (n || 0.0) if %(direction_id tender_type_id).exclude?(k)
          end
        end
      end

      def rows
        @rows ||= YAML.load(ERB.new(File.read("#{structures}/current_operation.yml")).result(binding))
      end

      COLUMNS = {
        c1: { type: :float, value: ->(r) { c12(r) + c14(r) } },
        c2: { type: :float, value: ->(r) { c13(r) + c15(r) } },
        c3: { type: :float, value: ->(r) { c1(r) == 0 ? 0 : c2(r) / c1(r) }, style: :td_percent },
        c4: { type: :float, value: ->(r) { to_thousand(r['kv1_cost'] || 0) } },
        c5: { type: :float, value: ->(r) { to_thousand(r['kv1_final_cost'] || 0) } },
        c6: { type: :float, value: ->(r) { to_thousand(r['kv2_cost'] || 0) } },
        c7: { type: :float, value: ->(r) { to_thousand(r['kv2_final_cost'] || 0) } },
        c8: { type: :float, value: ->(r) { c4(r) + c6(r) } },
        c9: { type: :float, value: ->(r) { c5(r) + c7(r) } },
        c10: { type: :float, value: ->(r) { to_thousand(r['kv3_cost'] || 0) } },
        c11: { type: :float, value: ->(r) { to_thousand(r['kv3_final_cost'] || 0) } },
        c12: { type: :float, value: ->(r) { c8(r) + c10(r) } },
        c13: { type: :float, value: ->(r) { c9(r) + c11(r) } },
        c14: { type: :float, value: ->(r) { to_thousand(r['kv4_cost'] || 0) } },
        c15: { type: :float, value: ->(r) { to_thousand(r['kv4_final_cost'] || 0) } }
      }

      COLUMNS.each_pair do |ckey, cval|
        define_singleton_method(ckey) { |r| cval[:value].call(r) }
      end
    end
  end
end

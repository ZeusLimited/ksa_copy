module Reports
  module Other
    class TemplateGeneration < Reports::Base
      FUEL = %w(газ уголь мазут)

      def default_params
        @default_params ||= {
          begin_date: date_begin.to_date,
          end_date: date_end.to_date,
          gkpz_year: gkpz_year.to_i
        }.with_indifferent_access
      end

      def plan_row(filter, fuel = nil)
        fuel_filter(plan_sql_rows, fuel).select do |row|
          filter.all? { |k, v| Array(v).include?(row[k.to_s]) }
        end.inject({}) do |h1, h2|
          h1.merge(h2) do |k, o, n|
            (o || 0.0) + (n || 0.0) if %(lot_name direction_id tender_type_id).exclude?(k)
          end
        end
      end

      def fact_row(filter, fuel = nil)
        fuel_filter(fact_sql_rows, fuel).select do |row|
          filter.all? { |k, v| Array(v).include?(row[k.to_s]) }
        end.inject({}) do |h1, h2|
          h1.merge(h2) do |k, o, n|
            (o || 0.0) + (n || 0.0) if %(lot_name direction_id tender_type_id).exclude?(k)
          end
        end
      end

      def result_row(filter, fuel = nil)
        plan_row(filter, fuel).merge(fact_row(filter, fuel))
      end

      def fuel_filter(rows, index)
        return rows unless index
        rows.select do |row|
          row['lot_name'].index(FUEL[index]) || (FUEL.all? { |a| !row['lot_name'].index(a) } && index == -1)
        end
      end

      def rows
        @rows ||= YAML.load(ERB.new(File.read("#{structures}/template_generation.yml")).result(binding))
      end

      COLUMNS = {
        c1: { type: :integer, value: ->(r) { r['plan_count'] }, style: :td },
        c2: { type: :integer, value: ->(r) { r['plan_count_etp'] }, style: :td },
        c3: { type: :string, formula: ->(i) { "=D#{i} / C#{i}" }, style: :td_percent },
        c4: { type: :float, value: ->(r) { to_thousand(r['plan_cost']) }, style: :td_money },
        c5: { type: :float, value: ->(r) { to_thousand(r['plan_cost_etp']) }, style: :td_money },
        c6: { type: :string, formula: ->(i) { "=G#{i} / F#{i}" }, style: :td_percent },
        c7: { type: :integer, value: ->(r) { r['kv1_count'] }, style: :td },
        c8: { type: :string, formula: ->(i) { "=I#{i} / C#{i}" }, style: :td_percent },
        c9: { type: :integer, value: ->(r) { r['kv1_count_etp'] }, style: :td },
        c10: { type: :string, formula: ->(i) { "=K#{i} / I#{i}" }, style: :td_percent },
        c11: { type: :string, formula: ->(i) { "=K#{i} / D#{i}" }, style: :td_percent },
        c12: { type: :float, value: ->(r) { to_thousand(r['kv1_final']) }, style: :td_money },
        c13: { type: :string, formula: ->(i) { "=N#{i} / F#{i}" }, style: :td_percent },
        c14: { type: :float, value: ->(r) { to_thousand(r['kv1_final_etp']) }, style: :td_money },
        c15: { type: :string, formula: ->(i) { "=P#{i} / N#{i}" }, style: :td_percent },
        c16: { type: :string, formula: ->(i) { "=P#{i} / G#{i}" }, style: :td_percent },
        c17: { type: :integer, value: ->(r) { r['kv2_count'] }, style: :td },
        c18: { type: :string, formula: ->(i) { "=S#{i} / C#{i}" }, style: :td_percent },
        c19: { type: :integer, value: ->(r) { r['kv2_count_etp'] }, style: :td },
        c20: { type: :string, formula: ->(i) { "=U#{i} / S#{i}" }, style: :td_percent },
        c21: { type: :string, formula: ->(i) { "=U#{i} / D#{i}" }, style: :td_percent },
        c22: { type: :float, value: ->(r) { to_thousand(r['kv2_final']) }, style: :td_money },
        c23: { type: :string, formula: ->(i) { "=X#{i} / F#{i}" }, style: :td_percent },
        c24: { type: :float, value: ->(r) { to_thousand(r['kv2_final_etp']) }, style: :td_money },
        c25: { type: :string, formula: ->(i) { "=Z#{i} / X#{i}" }, style: :td_percent },
        c26: { type: :string, formula: ->(i) { "=Z#{i} / G#{i}" }, style: :td_percent },
        c27: { type: :string, formula: ->(i) { "=I#{i} + S#{i}" }, style: :td },
        c28: { type: :string, formula: ->(i) { "=AC#{i} / C#{i}" }, style: :td_percent },
        c29: { type: :string, formula: ->(i) { "=K#{i} + U#{i}" }, style: :td },
        c30: { type: :string, formula: ->(i) { "=AE#{i} / AC#{i}" }, style: :td_percent },
        c31: { type: :string, formula: ->(i) { "=AE#{i} / D#{i}" }, style: :td_percent },
        c32: { type: :string, formula: ->(i) { "=N#{i} + X#{i}" }, style: :td_money },
        c33: { type: :string, formula: ->(i) { "=AH#{i} / F#{i}" }, style: :td_percent },
        c34: { type: :string, formula: ->(i) { "=P#{i} + Z#{i}" }, style: :td_money },
        c35: { type: :string, formula: ->(i) { "=AJ#{i} / AH#{i}" }, style: :td_percent },
        c36: { type: :string, formula: ->(i) { "=AJ#{i} / G#{i}" }, style: :td_percent },
        c37: { type: :integer, value: ->(r) { r['kv3_count'] }, style: :td },
        c38: { type: :string, formula: ->(i) { "=AM#{i} / C#{i}" }, style: :td_percent },
        c39: { type: :integer, value: ->(r) { r['kv3_count_etp'] }, style: :td },
        c40: { type: :string, formula: ->(i) { "=AO#{i} / AM#{i}" }, style: :td_percent },
        c41: { type: :string, formula: ->(i) { "=AO#{i} / D#{i}" }, style: :td_percent },
        c42: { type: :float, value: ->(r) { to_thousand(r['kv3_final']) }, style: :td_money },
        c43: { type: :string, formula: ->(i) { "=AR#{i} / F#{i}" }, style: :td_percent },
        c44: { type: :float, value: ->(r) { to_thousand(r['kv3_final_etp']) }, style: :td_money },
        c45: { type: :string, formula: ->(i) { "=AT#{i} / AR#{i}" }, style: :td_percent },
        c46: { type: :string, formula: ->(i) { "=AT#{i} / G#{i}" }, style: :td_percent },
        c47: { type: :string, formula: ->(i) { "=AC#{i} + AM#{i}" }, style: :td },
        c48: { type: :string, formula: ->(i) { "=AW#{i} / C#{i}" }, style: :td_percent },
        c49: { type: :string, formula: ->(i) { "=AE#{i} + AO#{i}" }, style: :td },
        c50: { type: :string, formula: ->(i) { "=AY#{i} / AW#{i}" }, style: :td_percent },
        c51: { type: :string, formula: ->(i) { "=AY#{i} / D#{i}" }, style: :td_percent },
        c52: { type: :string, formula: ->(i) { "=AH#{i} + AR#{i}" }, style: :td_money },
        c53: { type: :string, formula: ->(i) { "=BB#{i} / F#{i}" }, style: :td_percent },
        c54: { type: :string, formula: ->(i) { "=AJ#{i} + AT#{i}" }, style: :td_money },
        c55: { type: :string, formula: ->(i) { "=BD#{i} / BB#{i}" }, style: :td_percent },
        c56: { type: :string, formula: ->(i) { "=BD#{i} / G#{i}" }, style: :td_percent },
        c57: { type: :integer, value: ->(r) { r['kv4_count'] }, style: :td },
        c58: { type: :string, formula: ->(i) { "=BG#{i} / C#{i}" }, style: :td_percent },
        c59: { type: :integer, value: ->(r) { r['kv4_count_etp'] }, style: :td },
        c60: { type: :string, formula: ->(i) { "=BI#{i} / BG#{i}" }, style: :td_percent },
        c61: { type: :string, formula: ->(i) { "=BI#{i} / D#{i}" }, style: :td_percent },
        c62: { type: :float, value: ->(r) { to_thousand(r['kv4_final']) }, style: :td_money },
        c63: { type: :string, formula: ->(i) { "=BL#{i} / F#{i}" }, style: :td_percent },
        c64: { type: :float, value: ->(r) { to_thousand(r['kv4_final_etp']) }, style: :td_money },
        c65: { type: :string, formula: ->(i) { "=BN#{i} / BL#{i}" }, style: :td_percent },
        c66: { type: :string, formula: ->(i) { "=BN#{i} / G#{i}" }, style: :td_percent },
        c67: { type: :string, formula: ->(i) { "=AW#{i} + BG#{i}" }, style: :td },
        c68: { type: :string, formula: ->(i) { "=BQ#{i} / C#{i}" }, style: :td_percent },
        c69: { type: :string, formula: ->(i) { "=AY#{i} + BI#{i}" }, style: :td },
        c70: { type: :string, formula: ->(i) { "=BS#{i} / BQ#{i}" }, style: :td_percent },
        c71: { type: :string, formula: ->(i) { "=BS#{i} / D#{i}" }, style: :td_percent },
        c72: { type: :string, formula: ->(i) { "=BB#{i} + BL#{i}" }, style: :td_money },
        c73: { type: :string, formula: ->(i) { "=BV#{i} / F#{i}" }, style: :td_percent },
        c74: { type: :string, formula: ->(i) { "=BD#{i} + BN#{i}" }, style: :td_money },
        c75: { type: :string, formula: ->(i) { "=BX#{i} / BV#{i}" }, style: :td_percent },
        c76: { type: :string, formula: ->(i) { "=BX#{i} / G#{i}" }, style: :td_percent }
      }

      COLUMNS.each_pair do |ckey, cval|
        define_singleton_method(ckey) { |r| cval[:value].call(r) }
      end
    end
  end
end

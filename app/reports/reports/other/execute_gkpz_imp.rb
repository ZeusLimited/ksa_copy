module Reports
  module Other
    class ExecuteGkpzImp < Reports::Base
      def default_params
        @default_params ||= {
          begin_date: date_begin.to_date,
          end_date: date_end.to_date,
          date_gkpz_on_state: date_gkpz_on_state.to_date
        }.with_indifferent_access
      end

      def part1_row
        @part1_row ||= part1_sql_rows.first
      end

      def part2_row
        @part2_row ||= part2_sql_rows.first
      end

      def row_title(suffix, options = {})
        I18n.t("#{self.class.name.underscore}.row_titles.#{suffix}", options)
      end

      COLUMNS = {
        c1: { type: :string, style: :td_right, value: ->(r) { r['name'] }, width: 30, sum_style: :sum_money },
        c2: { type: :float, style: :td_money, value: ->(r) { r['cost_gr_1'] }, width: 20, sum_style: :sum_money },
        c3: { type: :float, style: :td_money, value: ->(r) { r['cost_gr_1_ei'] }, width: 20, sum_style: :sum_money },
        c2_1: { type: :integer, style: :td, value: ->(r) { r['cnt_gr_1'] }, width: 20, sum_style: :sum },
        c3_1: { type: :integer, style: :td, value: ->(r) { r['cnt_gr_1_ei'] }, width: 20, sum_style: :sum },
        c3_2: { type: :float, style: :td_money, value: ->(r) { r['cost_gr_1_closed'] }, width: 20, sum_style: :sum_money },
        c3_3: { type: :integer, style: :td, value: ->(r) { r['cnt_gr_1_closed'] }, width: 20, sum_style: :sum },
        c4: { type: :float, style: :td_money, value: ->(r) { r['cost_gr_2'] }, width: 30, sum_style: :sum_money },
        c5: { type: :float, style: :td_money, value: ->(r) { r['cost_gr_2_ei'] }, width: 30, sum_style: :sum_money },
        c4_1: { type: :integer, style: :td, value: ->(r) { r['cnt_gr_2'] }, width: 20, sum_style: :sum },
        c5_1: { type: :integer, style: :td, value: ->(r) { r['cnt_gr_2_ei'] }, width: 20, sum_style: :sum },
        c5_2: { type: :float, style: :td_money, value: ->(r) { r['cost_gr_2_closed'] }, width: 30, sum_style: :sum_money },
        c5_3: { type: :integer, style: :td, value: ->(r) { r['cnt_gr_2_closed'] }, width: 20, sum_style: :sum },
        c6: { type: :float, style: :td_money, value: ->(r) { r['cost_gr_3'] }, width: 20, sum_style: :sum_money },
        c7: { type: :float, style: :td_money, value: ->(r) { r['cost_gr_3_ei'] }, width: 20, sum_style: :sum_money },
        c7_1: { type: :float, style: :td_money, value: ->(r) { r['cost_gr_3_etp'] }, width: 20, sum_style: :sum_money },
        c7_2: { type: :float, style: :td_money, value: ->(r) { r['cost_gr_3_closed'] }, width: 20, sum_style: :sum_money },
        c8: { type: :float, style: :td_money, value: ->(r) { r['cost_gr_4'] }, width: 20, sum_style: :sum_money },
        c9: { type: :float, style: :td_money, value: ->(r) { r['cost_gr_4_ei'] }, width: 20, sum_style: :sum_money },
        c9_1: { type: :float, style: :td_money, value: ->(r) { r['cost_gr_4_etp'] }, width: 20, sum_style: :sum_money },
        c9_2: { type: :float, style: :td_money, value: ->(r) { r['cost_gr_4_closed'] }, width: 20, sum_style: :sum_money },
        c10: { type: :integer, style: :td, value: ->(r) { r['cnt_gr_4'] }, width: 20, sum_style: :sum },
        c11: { type: :integer, style: :td, value: ->(r) { r['cnt_gr_4_ei'] }, width: 20, sum_style: :sum },
        c12: { type: :integer, style: :td, value: ->(r) { r['cnt_gr_4_etp'] }, width: 20, sum_style: :sum },
        c13: { type: :integer, style: :td, value: ->(r) { r['cnt_gr_4_closed'] }, width: 20, sum_style: :sum },
        c14: { type: :string, formula: ->(i) { %[=N#{i}/B#{i}] }, style: :td_percent, sum_style: :sum_percent, width: 15 },
        c15: { type: :string, formula: ->(i) { %[=N#{i}/H#{i}] }, style: :td_percent, sum_style: :sum_percent, width: 15 },
        c16: { type: :string, formula: ->(i) { %[=O#{i}/N#{i}] }, style: :td_percent, sum_style: :sum_percent, width: 15 }
      }

      COLUMNS_EI = {
        c1: { type: :string, style: :td_right, value: ->(r) { r['name'] }, width: 30, sum_style: :sum_money },
        c2: { type: :float, style: :td_money, value: ->(r) { r['cost_gr_1'] }, width: 20, sum_style: :sum_money },
        c3: { type: :float, style: :td_money, value: ->(r) { r['cost_gr_2'] }, width: 20, sum_style: :sum_money }
      }

      COLUMNS.each_pair do |ckey, cval|
        define_singleton_method(ckey) { |r| cval[:value].call(r) }
      end

      COLUMNS_EI.each_pair do |ckey, cval|
        define_singleton_method(ckey) { |r| cval[:value].call(r) }
      end

    end
  end
end

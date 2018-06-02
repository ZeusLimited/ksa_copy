module Reports
  module Other
    class ExecuteGkpz < Reports::Base
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
        c4: { type: :float, style: :td_money, value: ->(r) { r['cost_gr_2'] }, width: 30, sum_style: :sum_money },
        c5: { type: :float, style: :td_money, value: ->(r) { r['cost_gr_2_ei'] }, width: 30, sum_style: :sum_money },
        c6: { type: :float, style: :td_money, value: ->(r) { r['cost_gr_3'] }, width: 20, sum_style: :sum_money },
        c7: { type: :float, style: :td_money, value: ->(r) { r['cost_gr_3_ei'] }, width: 20, sum_style: :sum_money },
        c8: { type: :float, style: :td_money, value: ->(r) { r['cost_gr_4'] }, width: 20, sum_style: :sum_money },
        c9: { type: :float, style: :td_money, value: ->(r) { r['cost_gr_4_ei'] }, width: 20, sum_style: :sum_money },
        c10: {
          type: :string, formula: ->(i) { %[=F#{i}/B#{i}] }, style: :td_percent, sum_style: :sum_percent, width: 15
        },
        c11: {
          type: :string, formula: ->(i) { %[=F#{i}/D#{i}] }, style: :td_percent, sum_style: :sum_percent, width: 15
        },
        c12: {
          type: :string, formula: ->(i) { %[=G#{i}/F#{i}] }, style: :td_percent, sum_style: :sum_percent, width: 15
        }
      }.freeze

      COLUMNS_EI = {
        c1: { type: :string, style: :td_right, value: ->(r) { r['name'] }, width: 30, sum_style: :sum_money },
        c2: { type: :float, style: :td_money, value: ->(r) { r['cost_gr_1'] }, width: 20, sum_style: :sum_money },
        c3: { type: :float, style: :td_money, value: ->(r) { r['cost_gr_2'] }, width: 20, sum_style: :sum_money },
        c4: {
          type: :string, formula: ->(i, _ii) { %[=C#{i}/B#{i}] }, style: :td_percent, sum_style: :sum_percent,
          width: 15
        },
        c5: {
          type: :string, formula: ->(i, ii) { %[=G#{i}/(F#{i}+B#{ii}+C#{ii})] }, style: :td_percent,
          sum_style: :sum_percent, width: 15
        },
        c6: {
          type: :string, formula: ->(i, ii) { %[=G#{i}/(F#{i}+C#{ii})] }, style: :td_percent, sum_style: :sum_percent,
          width: 15
        }
      }.freeze

      COLUMNS.each_pair do |ckey, cval|
        define_singleton_method(ckey) { |r| cval[:value].call(r) }
      end

      COLUMNS_EI.each_pair do |ckey, cval|
        define_singleton_method(ckey) { |r| cval[:value].call(r) }
      end

      def single_year?
        gkpz_years&.size == 1
      end
    end
  end
end

module Reports
  module Reglament
    class TotalExplanation < Reports::Base
      def fields
        @fields ||= YAML.load(ERB.new(File.read("#{structures}/total_explanation.yml")).result(binding))
      end

      def default_params
        @default_params ||= {
          begin_date: date_begin.to_date,
          end_date: date_end.to_date,
          init_date: Date.new(2015, 7, 1),
          gkpz_year: gkpz_year.to_i
        }.with_indifferent_access
      end

      def sheet1_row
        @sheet1_row ||= sheet1_sql_rows.first
      end

      def sheet2_plan_row
        @sheet2_plan_row ||= sheet2_plan_sql_rows.first
      end

      def sheet2_fact_row
        @sheet2_fact_row ||= sheet2_fact_sql_rows.first
      end

      def sheet2_2_rows
        @sheet2_2_rows ||= sheet2_2_sql_rows
      end

      def sheet2_2_invest_rows
        @sheet2_2_invest_rows ||= sheet2_2_rows.select { |r| r['direction_type'] == 'invest' }
      end

      def sheet2_2_tek_rows
        @sheet2_2_tek_rows ||= sheet2_2_rows.select { |r| r['direction_type'] == 'tek' }
      end

      def sheet2_3_rows
        @sheet2_3_rows ||= sheet2_3_sql_rows
      end

      def sheet2_4_rows
        @sheet2_4_rows ||= sheet2_4_sql_rows
      end

      def sheet3_1_rows
        @sheet3_1_rows ||= sheet3_1_sql_rows
      end

      def sheet3_2_rows
        @sheet3_2_rows ||= sheet3_2_sql_rows
      end

      def sheet3_3_row
        @sheet3_3_row ||= sheet3_3_sql_rows.first
      end

      def sheet4_row
        @sheet4_row ||= sheet4_sql_rows.first
      end

      def sheet5_rows
        @sheet5_rows ||= sheet5_sql_rows
      end

      def sheet6_row
        @sheet6_row ||= sheet6_sql_rows.first
      end

      def sheet6_sme_row
        @sheet6_sme_row ||= sheet6_sme_sql_rows.first
      end

      def months
        @months ||= calc_months
      end

      def calc_months
        self.date_end = date_end.to_date
        self.gkpz_year = gkpz_year.to_i
        date_begin_2_quarter = Date.new(gkpz_year, 4, 1)

        return 3 if date_end <= date_begin_2_quarter
        return date_end.month if date_end.year == gkpz_year
        12
      end
    end
  end
end

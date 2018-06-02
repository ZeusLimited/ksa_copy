module Reports
  module Reglament
    class PresentationTables < Reports::Base
      def slide2_structure
        @slide2_structure ||= YAML.load(ERB.new(File.read("#{structures}/presentation_tables/slide2.yml")).result(binding))
      end

      def slide3_structure
        @slide3_structure ||= YAML.load(ERB.new(File.read("#{structures}/presentation_tables/slide3.yml")).result)
      end

      def fields
        @fields ||= YAML.load(ERB.new(File.read("#{structures}/presentation_tables/slide5.yml")).result(binding))
      end

      def default_params
        @default_params ||= {
          begin_date: date_begin.to_date,
          end_date: date_end.to_date,
          gkpz_year: gkpz_year.to_i
        }.with_indifferent_access
      end

      def slide2_plan_rows_all
        @slide2_plan_rows_all ||= select_all(sanitize_sql([slide2_plan, default_params.merge(for_year: 1)]))
      end

      def slide2_plan_rows_period
        @slide2_plan_rows_period ||= select_all(sanitize_sql([slide2_plan, default_params.merge(for_year: 0)]))
      end

      def slide2_confirm_rows(filter = {})
        [slide2_confirm_sql_rows.select do |r|
          filter.all? { |k, v| Array(v).include?(r[k.to_s]) }
        end.inject({}) do |h1, h2|
          h1.merge(h2) do |k, o, n|
            o + (n || 0.0) if %(cnt cost_nds).include?(k.to_s)
          end
        end]
      end

      def slide3_total
        slide3_sql_rows.inject do |h1, h2|
          h1.merge(h2) do |key, old_val, new_val|
            old_val + (new_val || 0) if %(cnt cost_nds winner_cost_nds).include?(key.to_s)
          end
        end
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

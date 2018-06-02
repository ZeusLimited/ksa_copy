module Reports
  module Other
    class TendersEfficiency < Reports::Base
      def default_params
        @default_params ||= {
          begin_date: date_begin.to_date,
          end_date: date_end.to_date,
          gkpz_years: gkpz_years,
          fas_appeal: [0, 1],
          not_check_overdue: 1,
          excluded_tender_types: Constants::TenderTypes::NONCOMPETITIVE,
          wp_solution: [Constants::WinnerProtocolSolutionTypes::WINNER,
                        Constants::WinnerProtocolSolutionTypes::SINGLE_SOURCE]
        }.with_indifferent_access
      end

      def select_lots(filter)
        params = default_params.merge(filter.with_indifferent_access)
        select_all(sanitize_sql([efficiency, params]))
      end

      def report_parts
        @rows ||= YAML.load(ERB.new(File.read("#{structures}/tenders_efficiency.yml")).result(binding))
      end

      def self.efficiency_indicator(indicator_name, gkpz_years)
        gkpz_year = gkpz_years ? gkpz_years.last : Time.current.year
        effenciency_indicator = EffeciencyIndicator.find_by(work_name: indicator_name, gkpz_year: gkpz_year)
        effenciency_indicator ? effenciency_indicator.value : 0
      end

      def self.row_calculation(common, specific, indicator, gkpz_years)
        return 0 if common['cnt'].zero?
        if indicator == 'competitive_efficiency'
          100 - common['winners_cost'] / common['avg_cost'] * 100 >= efficiency_indicator(indicator, gkpz_years) ? 1 : 0
        else
          specific['cnt'] / common['cnt'] * 100 <= efficiency_indicator(indicator, gkpz_years) ? 1 : 0
        end
      end

      def self.head_calculation(results)
        result = 0
        results.each_pair do |key, value|
          result += value * EffeciencyIndicatorType.find_by(work_name: key).weight * 100
        end
        result.round.to_s + '%'
      end

      COLUMNS = {
        c1: { type: :string, title: true, style: :td, width: 50 },
        c2: { type: :string, style: :td, width: 20 }
      }
    end
  end
end

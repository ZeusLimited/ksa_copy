module Reports
  module Reglament
    class ConsolidatedAnalysis < Reports::Base

      POINT_CLAUSES = %w(5.11.1.5 5.9.1.4)

      EI_PP = '*Единственный источник п.5.11.1.5'

      def filter_pp
        @filter_pp ||= POINT_CLAUSES.map { |pp| "ri.num like '%#{pp}%'" }.join(' OR ')
      end

      def default_params
        @default_params ||= {
          begin_date: date_begin.to_date,
          end_date: date_end.to_date
        }.with_indifferent_access
      end
    end
  end
end

module Reports
  module Other
    class EconomicResultController < ApplicationController
      def options
        @options = EconomicResult.new(
          date_begin: Date.new(Time.current.year, 1, 1),
          date_end: Date.new(Time.current.year, 12, 31),
          gkpz_year: [Time.current.year]
        )
        render layout: false
      end

      def show
        @report = EconomicResult.new(economic_result_params)
        request.format = economic_result_params[:format]
        respond_to do |format|
          format.xlsx do
            render xlsx: "economic_result_#{Time.current.to_s(:number)}",
                   template: 'reports/other/economic_result/main'
          end
        end
      end

      private

      def economic_result_params
        params.require(:reports_other_economic_result)
              .permit(:date_begin, :date_end, :format, :gkpz_year, :state, subject_type: [],
                      customers: [], consumers: [], directions: [])
              .merge(current_user_root_dept_id: current_user.root_dept_id)
      end
    end
  end
end

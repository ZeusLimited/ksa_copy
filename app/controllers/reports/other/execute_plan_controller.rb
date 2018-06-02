module Reports
  module Other
    class ExecutePlanController < ApplicationController
      def options
        @options = ExecutePlan.new(
          cumulative_start_date: Date.new(Time.current.year, 1, 1),
          date_begin: Date.new(Time.current.year, 1, 1),
          date_end: Date.new(Time.current.year, 12, 31),
          gkpz_year: [Time.current.year]
        )
        render layout: false
      end

      def show
        @report = ExecutePlan.new(execute_plan_params)
        request.format = execute_plan_params[:format]
        respond_to do |format|
          format.xlsx do
            render xlsx: "execute_plan_#{Time.current.to_s(:number)}",
                   template: 'reports/other/execute_plan/main'
          end
        end
      end

      private

      def execute_plan_params
        params.require(:reports_other_execute_plan)
              .permit(:date_begin, :date_end, :format, :gkpz_year, :state, :cumulative_start_date,
                      customers: [], organizers: [], directions: [])
              .merge(current_user_root_dept_id: current_user.root_dept_id)
      end
    end
  end
end

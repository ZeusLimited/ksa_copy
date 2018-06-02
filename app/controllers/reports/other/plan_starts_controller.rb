module Reports
  module Other
    class PlanStartsController < ApplicationController
      prepend_view_path "app/models/reports/other/plan_starts"

      def options
        @options = Reports::Other::PlanStarts.new(
          date_begin: Date.new(Time.now.year - 1, 1, 1),
          date_end: Date.new(Time.now.year, 12, 31),
          gkpz_year: Time.now.year
        )
        render layout: false
      end

      def show
        @report = PlanStarts.new(plan_starts_params)

        request.format = plan_starts_params[:format]
        respond_to do |format|
          format.xlsx do
            render xlsx: "rep_plan_starts_#{Time.now.to_s(:number)}", template: 'reports/other/plan_starts/main'
          end
        end
      end

      private

      def plan_starts_params
        params
          .require(:reports_other_plan_starts)
          .permit(:date_begin, :date_end, :gkpz_year, :format,
                  customers: [], organizers: [], tender_types: [], statuses: [])
          .merge(current_user_root_dept_id: current_user.root_dept_id)
      end
    end
  end
end

module Reports
  module Other
    class TendersEfficiencyController < ApplicationController
      prepend_view_path "app/models/reports/other/tenders_efficiency"

      def options
        @options = Reports::Other::TendersEfficiency.new(
          date_begin: Date.new(Time.now.year, 1, 1),
          date_end: Date.new(Time.now.year, 12, 31),
          gkpz_years: [Time.now.year]
        )
        render layout: false
      end

      def show
        @report = Reports::Other::TendersEfficiency.new(tenders_efficiency_params)
        request.format = params[:format]
        respond_to do |format|
          format.xlsx do
            render xlsx: "Tenders_efficiency_#{Time.current.to_s(:number)}",
                   template: 'reports/other/tenders_efficiency/main'
          end
        end
      end

      private

      def tenders_efficiency_params
        params.require(:reports_other_tenders_efficiency)
              .permit(:date_begin, :date_end, :format, gkpz_years: [], customers: [], organizers: [])
              .merge(current_user_root_dept_id: current_user.root_dept_id)
      end
    end
  end
end

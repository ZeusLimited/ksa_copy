module Reports
  module Reglament
    class ConsolidatedAnalysisController < ApplicationController
      prepend_view_path "app/models/reports/reglament/consolidated_analysis"

      def options
        @options = ConsolidatedAnalysis.new(
          date_begin: Date.new(Time.now.year - 1, 1, 1),
          date_end: Date.new(Time.now.year, 12, 31),
          gkpz_years: [Time.now.year]
        )
        render layout: false
      end

      def show
        @report = ConsolidatedAnalysis.new(consolidated_analysis_params)

        request.format = consolidated_analysis_params[:format]
        respond_to do |format|
          format.xlsx do
            render xlsx: "rep2_9_#{Time.now.to_s(:number)}", template: 'reports/reglament/consolidated_analysis/main'
          end
        end
      end

      private

      def consolidated_analysis_params
        params.require(:reports_reglament_consolidated_analysis)
          .permit(:date_begin, :date_end, :format, gkpz_years: [], customers: [], organizers: [])
          .merge(current_user_root_dept_id: current_user.root_dept_id)
      end
    end
  end
end

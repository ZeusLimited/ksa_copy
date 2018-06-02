module Reports
  module Reglament
    class MounthlyAnalysisController < ApplicationController
      prepend_view_path "app/models/reports/reglament/mounthly_analysis"

      def options
        @options = MounthlyAnalysis.new(
          date_begin: Date.new(Time.now.year - 1, 1, 1),
          date_end: Date.new(Time.now.year, 12, 31),
          gkpz_years: [Time.now.year]
        )
        render layout: false
      end

      def show
        @report = MounthlyAnalysis.new(mounthly_analysis_params)

        request.format = mounthly_analysis_params[:format]
        respond_to do |format|
          format.xlsx do
            render xlsx: "rep2_8_#{Time.now.to_s(:number)}", template: 'reports/reglament/mounthly_analysis/main'
          end
          format.html do
            render template: 'reports/reglament/mounthly_analysis/main'
          end
        end
      end

      def detail
        @report = MounthlyAnalysis.new(detail_params)

        request.format = detail_params[:format]
        respond_to do |format|
          format.html do
            render template: "reports/reglament/mounthly_analysis/detail"
          end
        end
      end

      private

      def mounthly_analysis_params
        params.require(:reports_reglament_mounthly_analysis)
          .permit(:date_begin, :date_end, :format, gkpz_years: [], customers: [], organizers: [])
      end

      def detail_params
        params
          .permit(:line, :type, :date_begin, :date_end, :format, gkpz_years: [], customers: [], organizers: [])
          .merge(detail: true)
      end
    end
  end
end

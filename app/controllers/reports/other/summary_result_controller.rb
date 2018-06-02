module Reports
  module Other
    class SummaryResultController < ApplicationController
      prepend_view_path "app/models/reports/other/summary_result"

      def options
        @options = SummaryResult.new(
          date_begin: Date.new(Time.now.year - 1, 1, 1),
          date_end: Date.new(Time.now.year, 12, 31),
          gkpz_year: Time.now.year
        )
        render layout: false
      end

      def show
        @report = SummaryResult.new(summary_result_params)
        @report.current_user = current_user

        @report.sql = render_to_string("/sql", layout: false).to_str

        request.format = summary_result_params[:format]
        respond_to do |format|
          format.xlsx do
            render xlsx: "rep_summary_#{Time.now.to_s(:number)}", template: 'reports/other/summary_result/main'
          end
        end
      end

      private

      def summary_result_params
        params.require(:reports_other_summary_result)
          .permit(:date_begin, :date_end, :gkpz_year, :format, :subject_type,
                  customers: [], organizers: [], tender_types: [],
                  directions: [], financing_sources: [])
      end
    end
  end
end

module Reports
  module Other
    class TendersResultController < ApplicationController
      prepend_view_path "app/models/reports/other/tenders_result"

      def options
        @options = TendersResult.new(
          date_begin: Date.new(Time.current.year, 1, 1),
          date_end: Date.new(Time.current.year, 12, 31),
          gkpz_years: [Time.current.year]
        )
        render layout: false
      end

      def show
        @report = TendersResult.new(reports_other_tenders_result_params.to_h)
        request.format = reports_other_tenders_result_params[:format]
        respond_to do |format|
          format.xlsx do
            render xlsx: "tenders_result_5_12_#{Time.now.to_s(:number)}",
                   template: 'reports/other/tenders_result/main'
          end
          format.html { render template: 'reports/other/tenders_result/main' }
        end
      end

      private

      def reports_other_tenders_result_params
        params.require(:reports_other_tenders_result).permit(:date_begin, :date_end, :line, :row, :state, :format,
          :subject_type, consumers: [], directions: [], tender_types: [], customers: [], organizers: [],
          gkpz_years: []).merge(current_user_root_dept_id: current_user.root_dept_id)
      end
    end
  end
end

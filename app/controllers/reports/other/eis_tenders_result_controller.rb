module Reports
  module Other
    class EisTendersResultController < ApplicationController
      prepend_view_path "app/models/reports/other/eis_tenders_result"

      def options
        @options = EisTendersResult.new(
          date_begin: Date.new(Time.now.year-1, 1, 1),
          date_end: Date.new(Time.now.year, 12, 31)
        )
        render layout: false
      end

      def show
        @report = EisTendersResult.new(reports_other_eis_tenders_result_params)

        request.format = reports_other_eis_tenders_result_params[:format]
        respond_to do |format|
          format.xlsx do
            render xlsx: "eis_tenders_result_5_18_#{Time.now.to_s(:number)}",
                   template: 'reports/other/eis_tenders_result/main'
          end
        end
      end

      private

      def reports_other_eis_tenders_result_params
        params.require(:reports_other_eis_tenders_result).permit(:date_begin, :date_end,
          :format, customers: [], tender_types: []).merge(current_user_root_dept_id: current_user.root_dept_id)
      end
    end
  end
end

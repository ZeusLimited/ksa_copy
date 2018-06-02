module Reports
  module Other
    class VostekTendersController < ApplicationController
      prepend_view_path "app/models/reports/other/vostek_tenders"

      def options
        @options = Reports::Other::VostekTenders.new(
          date_begin: Date.current.beginning_of_month,
          date_end: Date.current.end_of_month,
          gkpz_years: [Time.now.year]
        )
        render layout: false
      end

      def show
        @report = Reports::Other::VostekTenders.new(vostek_tenders_params)

        request.format = vostek_tenders_params[:format]
        respond_to do |format|
          format.xlsx do
            render xlsx: "rep_vostek_tenders_#{Time.now.to_s(:number)}", template: 'reports/other/vostek_tenders/main'
          end
        end
      end

      private

      def vostek_tenders_params
        params.require(:reports_other_vostek_tenders)
          .permit(:date_begin, :date_end, :users, :format, customers: [], gkpz_years: [], organizers: [], directions: [])
          .merge(current_user_root_dept_id: current_user.root_dept_id)
      end
    end
  end
end

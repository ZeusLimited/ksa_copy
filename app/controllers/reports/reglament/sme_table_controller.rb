module Reports
  module Reglament
    class SmeTableController < ApplicationController
      prepend_view_path "app/models/reports/reglament/sme_table"

      def options
        @options = SmeTable.new(
          date_begin: Date.new(Time.now.year, 1, 1),
          date_end: Date.new(Time.now.year, 12, 31)
        )
        render layout: false
      end

      def show
        @report = SmeTable.new(sme_table_params)

        request.format = sme_table_params[:format]
        respond_to do |format|
          format.xlsx do
            render xlsx: "rep_2_6_#{Time.now.to_s(:number)}", template: 'reports/reglament/sme_table/main'
          end
        end
      end

      private

      def sme_table_params
        params.require(:reports_reglament_sme_table)
          .permit(:date_begin, :date_end, :format, :subject_type, gkpz_years: [],
                  customers: [], organizers: [], tender_types: [],
                  directions: [], financing_sources: [])
          .merge(current_user_root_dept_id: current_user.root_dept_id)
      end
    end
  end
end

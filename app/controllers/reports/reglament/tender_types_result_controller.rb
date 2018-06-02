module Reports
  module Reglament
    class TenderTypesResultController < ApplicationController
      prepend_view_path "app/models/reports/reglament/tender_types_result"

      def options
        @options = Reports::Reglament::TenderTypesResult.new(
          date_begin: Date.new(Time.now.year - 1, 1, 1),
          date_end: Date.new(Time.now.year, 12, 31),
          gkpz_year: Time.now.year
        )
        render layout: false
      end

      def show
        @report = Reports::Reglament::TenderTypesResult.new(tender_types_result_params)

        request.format = tender_types_result_params[:format]
        respond_to do |format|
          format.xlsx do
            render xlsx: "rep_2_4_#{Time.now.to_s(:number)}", template: 'reports/reglament/tender_types_result/main'
          end
        end
      end

      private

      def tender_types_result_params
        params.require(:reports_reglament_tender_types_result)
          .permit(:date_begin, :date_end, :customer, :gkpz_year, :format, :subject_type,
                  organizers: [], tender_types: [],
                  directions: [], financing_sources: [])
          .merge(current_user_root_dept_id: current_user.root_dept_id)
      end
    end
  end
end

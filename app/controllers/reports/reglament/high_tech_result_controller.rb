module Reports
  module Reglament
    class HighTechResultController < ApplicationController
      prepend_view_path "app/models/reports/reglament/high_tech_result"

      def options
        @options = HighTechResult.new(
          date_begin: Date.new(Time.now.year - 1, 1, 1),
          date_end: Date.new(Time.now.year, 12, 31),
          gkpz_year: Time.now.year
        )
        render layout: false
      end

      def show
        @report = HighTechResult.new(high_tech_result_params)

        request.format = high_tech_result_params[:format]
        respond_to do |format|
          format.xlsx do
            render xlsx: "rep_2_3_#{Time.now.to_s(:number)}", template: 'reports/reglament/high_tech_result/main'
          end
        end
      end

      private

      def high_tech_result_params
        params.require(:reports_reglament_high_tech_result)
          .permit(:date_begin, :date_end, :gkpz_year, :format, :subject_type, :show_root,
                  customers: [], organizers: [], tender_types: [],
                  directions: [], financing_sources: [])
          .merge(current_user_root_dept_id: current_user.root_dept_id)
      end
    end
  end
end

module Reports
  module Reglament
    class CurrentResultController < ApplicationController
      prepend_view_path "app/models/reports/reglament/current_result"

      def options
        @options = CurrentResult.new(
          date_begin: Date.new(Time.now.year - 1, 1, 1),
          date_end: Date.new(Time.now.year, 12, 31),
          gkpz_year: Time.now.year
        )
        render layout: false
      end

      def show
        @report = CurrentResult.new(current_result_params)

        request.format = current_result_params[:format]
        respond_to do |format|
          format.html { render layout: 'simple' }
          format.xlsx do
            render xlsx: "rep2_2_#{Time.now.to_s(:number)}", template: 'reports/reglament/current_result/main'
          end
        end
      end

      private

      def current_result_params
        params.require(:reports_reglament_current_result)
          .permit(:date_begin, :date_end, :customer, :gkpz_year, :format, :subject_type,
                  organizers: [], tender_types: [], consumers: [],
                  directions: [], financing_sources: [])
          .merge(current_user_root_dept_id: current_user.root_dept_id)
      end
    end
  end
end

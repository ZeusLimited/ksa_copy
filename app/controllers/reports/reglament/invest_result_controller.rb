module Reports
  module Reglament
    class InvestResultController < ApplicationController
      prepend_view_path "app/models/reports/reglament/invest_result"

      def options
        @options = InvestResult.new(
          date_begin: Date.new(Time.now.year - 1, 1, 1),
          date_end: Date.new(Time.now.year, 12, 31),
          gkpz_year: Time.now.year
        )
        render layout: false
      end

      def show
        @report = InvestResult.new(invest_result_params)

        request.format = invest_result_params[:format]
        respond_to do |format|
          format.xlsx do
            render xlsx: "reglament_1_#{Time.now.to_s(:number)}", template: 'reports/reglament/invest_result/main'
          end
        end
      end

      private

      def invest_result_params
        params.require(:reports_reglament_invest_result)
          .permit(:date_begin, :date_end, :gkpz_year, :format, :subject_type,
                  customers: [], organizers: [], tender_types: [],
                  directions: [], financing_sources: [])
          .merge(current_user_root_dept_id: current_user.root_dept_id)
      end
    end
  end
end

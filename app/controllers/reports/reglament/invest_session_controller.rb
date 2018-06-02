module Reports
  module Reglament
    class InvestSessionController < ApplicationController
      prepend_view_path "app/models/reports/reglament/invest_session"

      def options
        @options = InvestSession.new(
          date_begin: Date.new(Time.now.year - 1, 1, 1),
          date_end: Date.new(Time.now.year, 12, 31),
          gkpz_year: Time.now.year
        )
        render layout: false
      end

      def show
        @report = InvestSession.new(invest_session_params)

        request.format = invest_session_params[:format]
        respond_to do |format|
          format.xlsx do
            render xlsx: "rep_2_10_#{Time.now.to_s(:number)}", template: 'reports/reglament/invest_session/main'
          end
        end
      end

      private

      def invest_session_params
        params.require(:reports_reglament_invest_session)
          .permit(:date_begin, :date_end, :gkpz_year, :format, :subject_type,
                  customers: [], organizers: [], tender_types: [],
                  directions: [], financing_sources: [])
          .merge(current_user_root_dept_id: current_user.root_dept_id)
      end
    end
  end
end

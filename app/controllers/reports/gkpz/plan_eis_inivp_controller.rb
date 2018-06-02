module Reports
  module Gkpz
    class PlanEisInivpController < ApplicationController
      prepend_view_path "app/models/reports/gkpz/plan_eis_inivp"

      def options
        @options = Reports::Gkpz::PlanEisInivp.new(
          date_gkpz_on_state: Date.new(Time.now.year, 12, 31),
          begin_year: Time.now.year,
          end_year: Time.now.year + 4
        )
        render layout: false
      end

      def show
        @report = Reports::Gkpz::PlanEisInivp.new(reports_gkpz_plan_eis_inivp_params)

        render xlsx: "rep1_7_#{Time.now.to_s(:number)}",
               template: @report.template
      end

      private

      def reports_gkpz_plan_eis_inivp_params
        params.require(:reports_gkpz_plan_eis_inivp)
          .permit(
            :begin_year, :end_year, :date_gkpz_on_state, :gkpz_type, :with_sme, :etp, customers: [], organizers: [],
            statuses: [], address_etp: [], tender_types: [], directions: [], subject_types: [])
          .merge(current_user_root_dept_id: current_user.root_dept_id)
      end
    end
  end
end

module Reports
  module Gkpz
    class GkpzOosCommonController < ApplicationController
      prepend_view_path "app/models/reports/gkpz/oos"

      def options
        @options = Reports::Gkpz::GkpzOosCommon.new(
          date_gkpz_on_state: Date.new(Time.now.year, 12, 31),
          gkpz_year: Time.now.year
        )
        render layout: false
      end

      def show
        @report = Reports::Gkpz::GkpzOosCommon.new(reports_gkpz_oos_params)

        render xlsx: "rep1_6_#{Time.now.to_s(:number)}",
               template: @report.template
      end

      private

      def reports_gkpz_oos_params
        params.require(:reports_gkpz_gkpz_oos_common)
              .permit(:gkpz_year, :date_gkpz_on_state, :gkpz_type, :oos_etp,
                      customers: [], organizers: [], statuses: [], etp_addresses: [],
                      tender_types: [], directions: [], subject_types: [])
              .merge(current_user_root_dept_id: current_user.root_dept_id)
      end
    end
  end
end

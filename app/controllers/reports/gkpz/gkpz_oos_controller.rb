module Reports
  module Gkpz
    class GkpzOosController < ApplicationController
      prepend_view_path "app/models/reports/gkpz/gkpz_oos"

      def options
        @options = Reports::Gkpz::GkpzOos.new(
          date_gkpz_on_state: Date.new(Time.now.year, 12, 31),
          gkpz_year: Time.now.year
        )
        render layout: false
      end

      def show
        @rep_gkpz_oos = Reports::Gkpz::GkpzOos.new(reports_gkpz_gkpz_oos_params)

        respond_to do |format|
          format.xlsx do
            render xlsx: "rep1_2_#{Time.now.to_s(:number)}", template: 'reports/gkpz/gkpz_oos/main'
          end
        end
      end

      private

      def reports_gkpz_gkpz_oos_params
        params.require(:reports_gkpz_gkpz_oos)
          .permit(
            :gkpz_year, :date_gkpz_on_state, :gkpz_type, customer: [], organizer: [],
            status: [], address_etp: [], tender_type: [], direction: [], subject_type: [])
          .merge(current_user_root_dept_id: current_user.root_dept_id)
      end
    end
  end
end

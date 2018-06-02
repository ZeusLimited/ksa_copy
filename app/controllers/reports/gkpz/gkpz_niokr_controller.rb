module Reports
  module Gkpz
    class GkpzNiokrController < ApplicationController

      prepend_view_path "app/models/reports/gkpz/gkpz_niokr"

      def options
        @options = Reports::Gkpz::GkpzNiokr.new(
          date_begin: Date.new(Time.now.year - 1, 1, 1),
          date_end: Date.new(Time.now.year, 12, 31),
          date_gkpz_on_state: Date.new(Time.now.year, 12, 31),
          gkpz_year: [Time.now.year]
        )
        render layout: false
      end

      def show
        @report = Reports::Gkpz::GkpzNiokr.new(reports_gkpz_gkpz_niokr_params)

        respond_to do |format|
          format.xlsx do
            render xlsx: "rep_1_2_#{Time.now.to_s(:number)}", template: 'reports/gkpz/gkpz_niokr/main'
          end
        end
      end

      private

      def reports_gkpz_gkpz_niokr_params
        params.require(:reports_gkpz_gkpz_niokr)
          .permit(
            :date_begin, :date_end, :date_gkpz_on_state, :show_status, :gkpz_type, :gkpz_year, :customer, :gkpz_state,
            organizers: [], etp_addresses: [], tender_types: [], directions: [], subject_type: [], statuses: [])
          .merge(current_user_root_dept_id: current_user.root_dept_id)
      end
    end
  end
end

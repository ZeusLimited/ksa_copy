module Reports
  module Gkpz
    class ChecklistController < ApplicationController
      prepend_view_path "app/models/reports/gkpz/checklist"

      def options
        @options = Reports::Gkpz::Checklist.new(
          date_begin: Date.new(Time.now.year - 1, 1, 1),
          date_end: Date.new(Time.now.year, 12, 31),
          date_gkpz_on_state: Date.new(Time.now.year, 12, 31),
          gkpz_year: [Time.now.year]
        )
        render layout: false
      end

      def show
        @report = Reports::Gkpz::Checklist.new(reports_gkpz_checklist_params)

        respond_to do |format|
          format.xlsx do
            render xlsx: "rep_1_4_#{Time.now.to_s(:number)}",
                   template: 'reports/gkpz/checklist/main'
          end
        end
      end

      private

      def reports_gkpz_checklist_params
        params.require(:reports_gkpz_checklist)
          .permit(
            :date_begin, :date_end, :date_gkpz_on_state, :gkpz_type, :subject_type, :gkpz_year, :gkpz_state,
            :customer, organizers: [], tender_types: [], etp_addresses: [], directions: [], statuses: [])
          .merge(current_user_root_dept_id: current_user.root_dept_id)
      end
    end
  end
end

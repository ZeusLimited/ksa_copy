module Reports
  module Gkpz
    class GkpzExplanationController < ApplicationController
      prepend_view_path "app/models/reports/gkpz/gkpz_explanation"

      def options
        @options = Reports::Gkpz::GkpzExplanation.new(
          date_begin: Date.new(Time.now.year - 1, 1, 1),
          date_end: Date.new(Time.now.year, 12, 31),
          date_gkpz_on_state: Date.new(Time.now.year, 12, 31),
          gkpz_years: [Time.now.year]
        )
        render layout: false
      end

      def show
        @report = Reports::Gkpz::GkpzExplanation.new(reports_gkpz_gkpz_explanation_params)

        respond_to do |format|
          format.xlsx do
            render xlsx: "rep_1_5_#{Time.now.to_s(:number)}", template: 'reports/gkpz/gkpz_explanation/main'
          end
        end
      end

      private

      def reports_gkpz_gkpz_explanation_params
        params.require(:reports_gkpz_gkpz_explanation)
          .permit(
            :date_begin, :date_end, :date_gkpz_on_state, :gkpz_type, :gkpz_state,
            customers: [], organizers: [], gkpz_years: [], etp_addresses: [],
            tender_types: [], directions: [], subject_types: [], statuses: [])
          .merge(current_user_root_dept_id: current_user.root_dept_id)
      end
    end
  end
end

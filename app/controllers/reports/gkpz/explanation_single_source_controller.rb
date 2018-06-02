module Reports
  module Gkpz
    class ExplanationSingleSourceController < ApplicationController
      prepend_view_path "app/models/reports/gkpz/explanation_single_source"

      def options
        @options = Reports::Gkpz::ExplanationSingleSource.new(
          date_begin: Date.new(Time.now.year - 1, 1, 1),
          date_end: Date.new(Time.now.year, 12, 31),
          date_gkpz_on_state: Date.new(Time.now.year, 12, 31),
          gkpz_year: [Time.now.year]
        )
        render layout: false
      end

      def show
        @report = Reports::Gkpz::ExplanationSingleSource.new(reports_gkpz_explanation_single_source_params)

        respond_to do |format|
          format.xlsx do
            render xlsx: "rep_1_4_#{Time.now.to_s(:number)}",
                   template: 'reports/gkpz/explanation_single_source/main'
          end
        end
      end

      private

      def reports_gkpz_explanation_single_source_params
        params.require(:reports_gkpz_explanation_single_source)
          .permit(
            :date_begin, :date_end, :date_gkpz_on_state, :gkpz_type, :subject_type, :gkpz_state,
            :customer, organizers: [], gkpz_year: [],
            directions: [], statuses: [])
          .merge(current_user_root_dept_id: current_user.root_dept_id)
      end
    end
  end
end

module Reports
  module Reglament
    class TotalExplanationController < ApplicationController
      prepend_view_path "app/models/reports/reglament/total_explanation"

      def options
        @options = TotalExplanation.new(
          date_begin: Date.new(Time.now.year - 1, 1, 1),
          date_end: Date.new(Time.now.year, 12, 31),
          gkpz_year: Time.now.year
        )
        render layout: false
      end

      def show
        @report = TotalExplanation.new(total_explanation_params)

        request.format = total_explanation_params[:format]
        respond_to do |format|
          format.xlsx do
            render xlsx: "rep2_5_#{Time.now.to_s(:number)}", template: 'reports/reglament/total_explanation/main'
          end
        end
      end

      private

      def total_explanation_params
        params.require(:reports_reglament_total_explanation)
          .permit(:date_begin, :date_end, :gkpz_year, :format, customers: [], organizers: [])
          .merge(current_user_root_dept_id: current_user.root_dept_id)
      end
    end
  end
end

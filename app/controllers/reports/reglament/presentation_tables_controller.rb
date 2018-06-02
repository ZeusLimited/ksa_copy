module Reports
  module Reglament
    class PresentationTablesController < ApplicationController
      prepend_view_path "app/models/reports/reglament/presentation_tables"

      def options
        @options = PresentationTables.new(
          date_begin: Date.new((Time.current - 1.month).year - 1, 1, 1),
          date_end: Date.new((Time.current - 1.month).year, 12, 31),
          gkpz_year: (Time.current - 1.month).year
        )
        render layout: false
      end

      def show
        @report = PresentationTables.new(presentation_tables_params)
        request.format = presentation_tables_params[:format]

        render xlsx: "rep_2_11_#{Time.current.to_s(:number)}", template: 'reports/reglament/presentation_tables/main'
      end

      private

      def presentation_tables_params
        params.require(:reports_reglament_presentation_tables)
              .permit(:date_begin, :date_end, :format, :gkpz_year, customers: [], organizers: [])
              .merge(current_user_root_dept_id: current_user.root_dept_id)
      end
    end
  end
end

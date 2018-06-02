module Reports
  module Reglament
    class HundredMillionsTendersController < ApplicationController
      def options
        @options = HundredMillionsTenders.new(
          date_begin: Date.new(Time.now.year - 1, 1, 1),
          date_end: Date.new(Time.now.year, 12, 31),
          gkpz_years: [Time.now.year]
        )
        render layout: false
      end

      def show
        @report = HundredMillionsTenders.new(hundred_millions_params)

        request.format = hundred_millions_params[:format]
        respond_to do |format|
          format.xlsx do
            render(
              xlsx: "reglament_2_12_#{Time.now.to_s(:number)}",
              template: 'reports/reglament/hundred_millions_tenders/main')
          end
        end
      end

      private

      def hundred_millions_params
        params.require(:reports_reglament_hundred_millions_tenders)
              .permit(:date_begin, :date_end, :format, :subject_type, :contractors, :vz, :hundred_millions,
                      customers: [], organizers: [], tender_types: [], gkpz_years: [],
                      directions: [], financing_sources: [], nomenclature: [])
              .merge(current_user_root_dept_id: current_user.root_dept_id)
      end
    end
  end
end

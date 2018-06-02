module Reports
  module Reglament
    class IntermediateFormController < ApplicationController
      prepend_view_path "app/models/reports/reglament/intermediate_form"

      def options
        @options = IntermediateForm.new(
          date_begin: Date.new(Time.now.year - 1, 1, 1),
          date_end: Date.new(Time.now.year, 12, 31),
          gkpz_years: [Time.now.year]
        )
        render layout: false
      end

      def show
        @report = IntermediateForm.new(intermediate_form_params)

        request.format = intermediate_form_params[:format]
        respond_to do |format|
          format.xlsx do
            render(
              xlsx: "reglament_2_7_#{Time.now.to_s(:number)}",
              template: 'reports/reglament/intermediate_form/main')
          end
        end
      end

      private

      def intermediate_form_params
        params.require(:reports_reglament_intermediate_form)
          .permit(:date_begin, :date_end, :format, :subject_type, :vz,
                  customers: [], organizers: [], tender_types: [], gkpz_years: [],
                  directions: [], financing_sources: [])
          .merge(current_user_root_dept_id: current_user.root_dept_id)
      end
    end
  end
end

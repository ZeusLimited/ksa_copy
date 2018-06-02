module Reports
  module Other
    class TemplateGenerationController < ApplicationController
      prepend_view_path "app/models/reports/other/template_generation"

      def options
        @options = TemplateGeneration.new(
          date_begin: Date.new(Time.now.year - 1, 1, 1),
          date_end: Date.new(Time.now.year, 12, 31),
          gkpz_year: Time.now.year
        )
        render layout: false
      end

      def show
        @report = TemplateGeneration.new(template_generation_params)

        request.format = template_generation_params[:format]
        respond_to do |format|
          format.xlsx do
            render xlsx: "rep_generation_#{Time.now.to_s(:number)}", template: 'reports/other/template_generation/main'
          end
        end
      end

      private

      def template_generation_params
        params.require(:reports_other_template_generation)
          .permit(:date_begin, :date_end, :gkpz_year, :format, :subject_type, :customer,
                  organizers: [], tender_types: [],
                  directions: [], financing_sources: [])
          .merge(current_user_root_dept_id: current_user.root_dept_id)
      end
    end
  end
end

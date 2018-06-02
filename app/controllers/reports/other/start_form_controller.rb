module Reports
  module Other
    class StartFormController < ApplicationController
      prepend_view_path "app/models/reports/other/start_form"

      def options
        @options = Reports::Other::StartForm.new(
          date_begin: (Time.now.to_date - 7.days),
          date_end: (Time.now.to_date),
          gkpz_year: Time.now.year
        )
        render layout: false
      end

      def show
        @report = StartForm.new(start_form_params)

        request.format = start_form_params[:format]
        respond_to do |format|
          format.xlsx do
            render xlsx: "rep_start_form_#{Time.now.to_s(:number)}", template: 'reports/other/start_form/main'
          end
        end
      end

      private

      def start_form_params
        params.require(:reports_other_start_form)
              .permit(:date_begin, :date_end, :format, gkpz_year: [], customers: [], organizers: [], tender_types: [],
                directions: [])
              .merge(current_user_root_dept: current_user.root_dept)
      end
    end
  end
end

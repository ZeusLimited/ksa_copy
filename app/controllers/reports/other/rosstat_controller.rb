module Reports
  module Other
    class RosstatController < ApplicationController
      prepend_view_path "app/models/reports/other/rosstat"

      def options
        @options = Rosstat.new(
          date_begin: Date.new(Time.now.year - 1, 1, 1),
          date_end: Date.new(Time.now.year, 12, 31),
          gkpz_year: Time.now.year
        )
        render layout: false
      end

      def show
        @report = Rosstat.new(rosstat_params)

        @rows = YAML.load(File.new("app/views/reports/other/rosstat/yaml/part1.yml").read)

        request.format = rosstat_params[:format]
        respond_to do |format|
          format.xlsx do
            render xlsx: "rep_rosstat_#{Time.now.to_s(:number)}", template: 'reports/other/rosstat/main'
          end
          format.html do
            render template: 'reports/other/rosstat/main'
          end
        end
      end

      def detail
        @report = Rosstat.new(detail_params)

        request.format = detail_params[:format]
        render template: "reports/other/rosstat/detail"
      end

      private

      def rosstat_params
        params.require(:reports_other_rosstat)
          .permit(:date_begin, :date_end, :gkpz_year, :format, :subject_type, :customer,
                  organizers: [], tender_types: [],
                  directions: [], financing_sources: [])
          .merge(current_user_root_dept_id: current_user.root_dept_id)
      end

      def detail_params
        params
          .permit(:col, :line, :detail, :date_begin, :date_end, :gkpz_year, :format, :subject_type, :customer,
                  organizers: [], tender_types: [],
                  directions: [], financing_sources: [])
          .merge(detail: true, current_user_root_dept_id: current_user.root_dept_id)
      end
    end
  end
end

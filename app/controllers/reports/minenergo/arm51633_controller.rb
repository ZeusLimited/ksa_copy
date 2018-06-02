module Reports
  module Minenergo
    class Arm51633Controller < ApplicationController
      prepend_view_path "app/models/reports/minenergo/arm51633"

      def options
        @options = Reports::Minenergo::Arm51633.new(
          date_begin: Date.new(Time.now.year - 1, 1, 1),
          date_end: Date.new(Time.now.year, 12, 31),
          gkpz_year: [Time.now.year]
        )
        render layout: false
      end

      def show
        @report = Reports::Minenergo::Arm51633.new(arm51633_params)

        request.format = arm51633_params[:format]
        respond_to do |format|
          format.text do
            quarter = Date.parse(arm51633_params[:date_end]).end_of_quarter.strftime('%y%m')
            arm_dept = ArmDepartment.where(department_id: arm51633_params[:customer]).pluck(:arm_id).first
            send_data @report.generate_special_file(arm_dept, quarter).to_s.encode(Encoding::IBM866, replace: ''),
                      filename: "#{arm_dept}_51633.#{quarter}"
          end
          format.xlsx do
            render xlsx: "minenergo_51633_#{Time.now.to_s(:number)}", template: 'reports/minenergo/arm51633/main'
          end
        end
      end

      private

      def arm51633_params
        params.require(:reports_minenergo_arm51633)
          .permit(:date_begin, :date_end, :customer, :organizers, :gkpz_year, :format, :subject_type,
                  :par55555, :par77777,
                  organizers: [], tender_types: [],
                  directions: [], financing_sources: [])
      end
    end
  end
end

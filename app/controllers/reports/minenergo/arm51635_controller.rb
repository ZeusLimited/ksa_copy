module Reports
  module Minenergo
    class Arm51635Controller < ApplicationController
      prepend_view_path "app/models/reports/minenergo/arm51635"

      def options
        @options = Reports::Minenergo::Arm51635.new(
          date_begin: Date.new(Time.now.year - 1, 1, 1),
          date_end: Date.new(Time.now.year, 12, 31),
          date_gkpz_on_state: Date.new(Time.now.year, 12, 31),
          gkpz_year: [Time.now.year]
        )
        render layout: false
      end

      def show
        @report = Reports::Minenergo::Arm51635.new(arm51635_params)

        request.format = arm51635_params[:format]
        respond_to do |format|
          format.text do
            quarter = Date.parse(arm51635_params[:date_end]).end_of_quarter.strftime('%y%m')
            arm_dept = ArmDepartment.where(department_id: arm51635_params[:customer]).pluck(:arm_id).first
            send_data @report.generate_special_file(arm_dept, quarter).to_s.encode(Encoding::IBM866, replace: ''),
                      filename: "#{arm_dept}_51635.#{quarter}"
          end
          format.xlsx do
            render xlsx: "minenergo_51635_#{Time.now.to_s(:number)}", template: 'reports/minenergo/arm51635/main'
          end
        end
      end

      private

      def arm51635_params
        params.require(:reports_minenergo_arm51635)
          .permit(:date_begin, :date_end, :customer, :organizers, :format, :subject_type, :gkpz_type,
                  :par55555, :par77777, :par22222, :date_gkpz_on_state,
                  gkpz_year: [], organizers: [], tender_types: [], statuses: [],
                  directions: [], financing_sources: [], consumers: [])
      end
    end
  end
end

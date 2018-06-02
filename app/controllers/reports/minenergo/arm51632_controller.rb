module Reports
  module Minenergo
    class Arm51632Controller < ApplicationController
      prepend_view_path "app/models/reports/minenergo/arm51632"

      def options
        @options = Reports::Minenergo::Arm51632.new(
          date_begin: Date.new(Time.now.year - 1, 1, 1),
          date_end: Date.new(Time.now.year, 12, 31),
          gkpz_years: [Time.now.year]
        )
        render layout: false
      end

      def show
        @report = Reports::Minenergo::Arm51632.new(arm51632_params)
        request.format = arm51632_params[:format]
        respond_to do |format|
          format.text do
            quarter = Date.parse(arm51632_params[:date_end]).end_of_quarter.strftime('%y%m')
            arm_dept = ArmDepartment.where(department_id: arm51632_params[:customer]).pluck(:arm_id).first
            send_data @report.generate_special_file(arm_dept, quarter).to_s.encode(Encoding::IBM866, replace: ''),
                      filename: "#{arm_dept}_51632.#{quarter}"
          end
          format.xlsx do
            render xlsx: "minenergo_51632_#{Time.now.to_s(:number)}", template: 'reports/minenergo/arm51632/main'
          end
        end
      end

      private

      def arm51632_params
        params.require(:reports_minenergo_arm51632)
          .permit(:date_begin, :date_end, :customer, :organizers, :format, :subject_type,
                  :par22222, :par22222_ps, :par33333, :par33333_ps, :par44444, :par44444_ps,
                  :par55555, :par77777, :winners, consumers: [],
                  gkpz_years: [], organizers: [], tender_types: [],
                  directions: [], financing_sources: [])
      end
    end
  end
end

module Reports
  module Other
    class ExecuteGkpzController < ApplicationController
      prepend_view_path "app/models/reports/other/execute_gkpz"

      def options
        @options = ExecuteGkpz.new(
          date_begin: Date.new(Time.now.year, 1, 1),
          date_end: Date.new(Time.now.year, 12, 31),
          date_gkpz_on_state: Date.current,
          gkpz_years: [Time.now.year]
        )
        render layout: false
      end

      def show
        @detail_params = ActionController::Parameters.new(reports_other_execute_gkpz: reports_other_execute_gkpz_params)
        @report = ExecuteGkpz.new(reports_other_execute_gkpz_params)

        request.format = reports_other_execute_gkpz_params[:format]
        respond_to do |format|
          format.xlsx do
            render xlsx: "execute_gkpz_5_3_2_#{Time.now.to_s(:number)}",
                   template: 'reports/other/execute_gkpz/main'
          end
          format.html { render template: 'reports/other/execute_gkpz/main' }
        end
      end

      private

      def reports_other_execute_gkpz_params
        params.require(:reports_other_execute_gkpz).permit(:date_begin, :date_end, :date_gkpz_on_state, :line, :row,
          :format, customers: [], organizers: [], gkpz_years: []).merge(current_user_root_dept_id: current_user.root_dept_id)
      end

    end
  end
end

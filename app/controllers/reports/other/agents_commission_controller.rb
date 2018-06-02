module Reports
  module Other
    class AgentsCommissionController < ApplicationController
      prepend_view_path "app/models/reports/other/agents_commission"

      def options
        @options = Reports::Other::AgentsCommission.new(
          date_begin: Date.new(Time.now.year, 1, 1),
          date_end: Date.new(Time.now.year, 12, 31),
          gkpz_years: [Time.now.year]
        )
        render layout: false
      end

      def show
        @report = Reports::Other::AgentsCommission.new(agents_commission_params)
        #render plain: agents_commission_params
        request.format = params[:format]
        respond_to do |format|
          format.xlsx do
            render xlsx: "Agents_commission_#{Time.now.to_s(:number)}", template: 'reports/other/agents_commission/main'
          end
        end
      end

      private

      def agents_commission_params
        params.require(:reports_other_agents_commission)
          .permit(:date_begin, :date_end, :format, :lot_num, gkpz_years: [], customers: [], organizers: [], plan_lot_statuses: [], lot_statuses: [])
          .merge(current_user_root_dept_id: current_user.root_dept_id)
      end

    end
  end
end

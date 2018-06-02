module Reports
  module Other
    class OverdueContractController < ApplicationController
      prepend_view_path "app/models/reports/other/overdue_contract"

      def options
        @options = OverdueContract.new(
          date_begin: Date.new(Time.now.year - 1, 1, 1),
          date_end: Date.new(Time.now.year, 12, 31),
          gkpz_year: Time.now.year
        )
        render layout: false
      end

      def show
        @report = OverdueContract.new(overdue_contract_params)

        request.format = overdue_contract_params[:format]
        respond_to do |format|
          format.xlsx do
            render xlsx: "rep_overdue_#{Time.now.to_s(:number)}", template: 'reports/other/overdue_contract/main'
          end
        end
      end

      private

      def overdue_contract_params
        params.require(:reports_other_overdue_contract)
          .permit(:date_begin, :date_end, :gkpz_year, :format, :subject_type,
                  customers: [],
                  organizers: [], tender_types: [],
                  directions: [], financing_sources: [])
          .merge(current_user_root_dept_id: current_user.root_dept_id)
      end
    end
  end
end

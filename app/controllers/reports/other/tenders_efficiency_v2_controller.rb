module Reports
  module Other
    class TendersEfficiencyV2Controller < ApplicationController

      def options
        @options = TendersEfficiencyV2.new(
          date_begin: Date.new(Time.now.year - 1, 1, 1),
          date_end: Date.new(Time.now.year, 12, 31),
          gkpz_years: [Time.now.year]
        )
        render layout: false
      end

      def show
        @report = TendersEfficiencyV2.new(tenders_efficiency_v2_params)

        request.format = tenders_efficiency_v2_params[:format]
        respond_to do |format|
          format.xlsx do
            render xlsx: "rep_5_11_#{Time.now.to_s(:number)}", template: 'reports/other/tenders_efficiency_v2/main'
          end
        end
      end

      private

      def tenders_efficiency_v2_params
        params.require(:reports_other_tenders_efficiency_v2)
          .permit(:date_begin, :date_end, :format, :subject_type,
                  customers: [], organizers: [], tender_types: [],
                  directions: [], financing_sources: [], gkpz_years: [])
          .merge(current_user_root_dept_id: current_user.root_dept_id)
      end
    end
  end
end

module Reports
  module Other
    class TenderBiddersController < ApplicationController
      prepend_view_path "app/models/reports/other/tender_bidders"

      def options
        @options = TenderBidders.new(
          date_begin: Date.new(Time.now.year - 1, 1, 1),
          date_end: Date.new(Time.now.year, 12, 31),
          gkpz_years: [Time.now.year]
        )
        render layout: false
      end

      def show
        @report = TenderBidders.new(tender_bidders_params)

        request.format = tender_bidders_params[:format]
        respond_to do |format|
          format.xlsx do
            render xlsx: "rep_tender_bidders_#{Time.now.to_s(:number)}", template: 'reports/other/tender_bidders/main'
          end
        end
      end

      private

      def tender_bidders_params
        params.require(:reports_other_tender_bidders)
              .permit(:date_begin, :date_end, :contractors, :format, etp_addresses: [], tender_types: [],
                      customers: [], organizers: [], directions: [], gkpz_years: [])
              .merge(current_user_root_dept_id: current_user.root_dept_id)
      end
    end
  end
end

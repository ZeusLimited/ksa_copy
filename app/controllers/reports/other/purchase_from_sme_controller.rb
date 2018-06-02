module Reports
  module Other
    class PurchaseFromSmeController < ApplicationController
      prepend_view_path "app/models/reports/other/purchase_from_sme"

      def options
        @options = Reports::Other::PurchaseFromSme.new(
          date_begin: Date.new(Time.now.year, 1, 1),
          date_end: Date.new(Time.now.year, 12, 31)
        )
        render layout: false
      end

      def show
        @sme_params = ActionController::Parameters.new(reports_other_purchase_from_sme: purchase_from_sme_params)
        @report = Reports::Other::PurchaseFromSme.new(purchase_from_sme_params)
        @rows = PurchaseFromSme::ROWS

        request.format = purchase_from_sme_params[:format]
        respond_to do |format|
          format.xlsx do
            render xlsx: "rep_purchase_from_sme_#{Time.now.to_s(:number)}",
                   template: 'reports/other/purchase_from_sme/main'
          end
          format.html { render template: "reports/other/purchase_from_sme/main_#{Setting.company}" }
        end
      end

      def detail
        @report = Reports::Other::PurchaseFromSme.new(purchase_from_sme_params)
        render template: "reports/other/purchase_from_sme/detail_#{Setting.company}"
      end

      private

      def purchase_from_sme_params
        params.require(:reports_other_purchase_from_sme)
          .permit(:date_begin, :date_end, :format, :detail, :line, :row, :filter_rows, customers: [], order: [], organizers: [])
          .merge(current_user_root_dept_id: current_user.root_dept_id)
      end
    end
  end
end

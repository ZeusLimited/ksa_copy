module Reports
  module Other
    class InovationProductController < ApplicationController
      prepend_view_path "app/models/reports/other/inovation_product"

      def options
        @options = InovationProduct.new(
          date_begin: Date.new(Time.now.year, 1, 1),
          date_end: Date.new(Time.now.year, 12, 31)
        )
        render layout: false
      end

      def show
        @detail_params = ActionController::Parameters.new(reports_other_inovation_product: report_inovation_product_params)
        @report = InovationProduct.new(report_inovation_product_params)

        request.format = report_inovation_product_params[:format]
        respond_to do |format|
          format.xlsx do
            render xlsx: "inovation_5_8_#{Time.now.to_s(:number)}",
                   template: 'reports/other/inovation_product/main'
          end
          format.html { render template: 'reports/other/inovation_product/main' }
        end
      end

      def detail
        @report = InovationProduct.new(report_inovation_product_params)
        render template: 'reports/other/inovation_product/detail'
      end

      private

      def report_inovation_product_params
        params.require(:reports_other_inovation_product).permit(:date_begin, :date_end, :detail, :line, :row, :format, :target_place,
          customers: [], organizers: [])
      end
    end
  end
end

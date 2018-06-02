module Reports
  module Other
    module InovationProductAmountHelper
      def inovation_product_amount_detail(detail_params, value, line, row, filter_rows = nil)
        detail_params[:reports_other_inovation_product_amount].merge!(line: line, row: row, filter_rows: filter_rows, detail: true)
        link_to value, reports_other_inovation_product_amount_detail_path(detail_params.permit!), target: '_blank'
      end
    end
  end
end

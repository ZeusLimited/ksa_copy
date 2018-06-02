module Reports
  module Other
    module InovationProductHelper
      def inovation_product_detail(detail_params, value, line, row)
        detail_params[:reports_other_inovation_product].merge!(line: line, row: row, detail: true)
        link_to value, reports_other_inovation_product_detail_path(detail_params.permit!), target: '_blank'
      end
    end
  end
end

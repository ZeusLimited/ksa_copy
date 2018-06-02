module Reports
  module Other
    module PurchaseFromSmeHelper
      def purchase_from_sme_detail(sme_params, value, line, row, filter_rows = nil, order = nil)
        sme_params[:reports_other_purchase_from_sme].merge!(line: line, row: row, order: order, filter_rows: filter_rows, detail: true)
        link_to value, reports_other_purchase_from_sme_detail_path(sme_params.permit!), target: '_blank'
      end
    end
  end
end

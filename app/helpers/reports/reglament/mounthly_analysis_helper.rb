module Reports
  module Reglament
    module MounthlyAnalysisHelper
      def link_to_detail(value, line, column)
        return if value.nil?
        type = %i[c3 c4 c5].include?(column) ? '_all' : ''
        params[:reports_reglament_mounthly_analysis].merge!(line: line, type: type, detail: true).permit!
        link_to value,
                reports_reglament_mounthly_analysis_detail_path(params[:reports_reglament_mounthly_analysis]),
                target: :_blank
      end
    end
  end
end

module Reports
  module Other
    module RosstatHelper
      def link_to_detail_rosstat(value, col, line)
        pars = params[:reports_other_rosstat].merge(line: line, col: col, detail: true)
        link_to value, reports_other_rosstat_detail_path(pars.permit!), target: '_blank'
      end

    end
  end
end

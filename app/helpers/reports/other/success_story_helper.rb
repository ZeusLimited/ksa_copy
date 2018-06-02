module Reports
  module Other
    module SuccessStoryHelper
      def success_story_detail(detail_params, value, lot_id)
        detail_params[:reports_other_success_story].merge!(lot_id: lot_id)
        link_to value, reports_other_success_story_detail_path(detail_params.permit!), target: '_blank'
      end
    end
  end
end

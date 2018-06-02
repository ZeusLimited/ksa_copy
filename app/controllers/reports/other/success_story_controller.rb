module Reports
  module Other
    class SuccessStoryController < ApplicationController
      prepend_view_path "app/models/reports/other/success_story"

      def options
        @options = Reports::Other::SuccessStory.new(
          date_begin: Date.new(Time.now.year, 1, 1),
          date_end: Date.new(Time.now.year, 12, 31)
        )
        render layout: false
      end

      def show
        @success_params = ActionController::Parameters.new(reports_other_success_story: success_story_params)
        @report = Reports::Other::SuccessStory.new(success_story_params)
        request.format = success_story_params[:format]
        respond_to do |format|
          format.xlsx do
            render xlsx: "success_story_#{Time.now.to_s(:number)}", template: 'reports/other/success_story/main'
          end
          format.html do
            render template: 'reports/other/success_story/main'
          end
        end
      end

      def detail
        @report = Reports::Other::SuccessStory.new(success_story_params)
        render template: 'reports/other/success_story/detail'
      end

      private

      def success_story_params
        params.require(:reports_other_success_story)
              .permit(:date_begin, :date_end, :format, :lot_id, customers: [], organizers: [])
              .merge(current_user_root_dept_id: current_user.root_dept_id)
      end
    end
  end
end
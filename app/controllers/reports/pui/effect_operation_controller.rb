module Reports
  module Pui
    class EffectOperationController < ApplicationController
      prepend_view_path "app/models/reports/pui/effect_operation"

      def options
        @options = EffectOperation.new(
          date_begin: Date.new(Time.now.year - 1, 1, 1),
          date_end: Date.new(Time.now.year, 12, 31),
          gkpz_year: Time.now.year
        )
        render layout: false
      end

      def show
        @report = EffectOperation.new(effect_operation_params)

        request.format = effect_operation_params[:format]
        respond_to do |format|
          format.xlsx do
            render xlsx: "rep_4_1_#{Time.now.to_s(:number)}", template: 'reports/pui/effect_operation/main'
          end
        end
      end

      private

      def effect_operation_params
        params.require(:reports_pui_effect_operation)
          .permit(:date_begin, :date_end, :customer, :gkpz_year, :format,
                  organizers: [], directions: [])
          .merge(current_user_root_dept_id: current_user.root_dept_id)
      end
    end
  end
end

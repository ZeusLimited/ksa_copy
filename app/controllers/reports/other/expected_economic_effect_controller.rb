module Reports
  module Other
    class ExpectedEconomicEffectController < ApplicationController
      prepend_view_path "app/models/reports/other/expected_economic_effect"

      def options
        @options = ExpectedEconomicEffect.new(
          date_begin: Date.new(Time.now.year - 1, 1, 1),
          date_end: Date.new(Time.now.year, 12, 31),
          gkpz_year: Time.now.year
        )
        render layout: false
      end

      def show
        @report = ExpectedEconomicEffect.new(rep_params)

        render xlsx: "rep_eee_#{Time.now.to_s(:number)}", template: 'reports/other/expected_economic_effect/main'
      end

      private

      def rep_params
        params.require(:reports_other_expected_economic_effect)
          .permit(:date_begin, :date_end, :gkpz_year, customers: [], organizers: [], directions: [])
          .merge(current_user_root_dept_id: current_user.root_dept_id)
      end
    end
  end
end

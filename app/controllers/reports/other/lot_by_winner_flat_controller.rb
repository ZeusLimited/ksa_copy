module Reports
  module Other
    class LotByWinnerFlatController < ApplicationController
      prepend_view_path "app/models/reports/other/lot_by_winner_flat"

      def options
        @options = Reports::Other::LotByWinnerFlat.new(
          date_begin: Date.new(Time.now.year, 1, 1),
          date_end: Date.new(Time.now.year, 12, 31),
          gkpz_years: [Time.now.year]
        )

        render layout: false
      end

      def show
        @report = Reports::Other::LotByWinnerFlat.new(lot_by_winner_flat_params)
        request.format = params[:format]
        respond_to do |format|
          format.xlsx do
            render xlsx: "Rep_lot_by_winner_flat_#{Time.now.to_s(:number)}", template: 'reports/other/lot_by_winner_flat/main'
          end
        end
      end

      private

      def lot_by_winner_flat_params
        params.require(:reports_other_lot_by_winner_flat)
          .permit(:date_begin, :date_end, :format, :winners, gkpz_years: [], customers: [], organizers: [], directions: [])
          .merge(current_user_root_dept_id: current_user.root_dept_id)
      end

    end
  end
end

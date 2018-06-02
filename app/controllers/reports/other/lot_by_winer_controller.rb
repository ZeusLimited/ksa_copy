module Reports
  module Other
    class LotByWinerController < ApplicationController
      prepend_view_path "app/models/reports/other/lot_by_winer"

      def options
        @options = Reports::Other::LotByWiner.new(
          date_begin: Date.new(Time.now.year, 1, 1),
          date_end: Date.new(Time.now.year, 12, 31),
          gkpz_years: [Time.now.year]
        )

        render layout: false
      end

      def show
        @report = Reports::Other::LotByWiner.new(lot_by_winer_params)
        #render plain: lot_by_winer_params
        request.format = params[:format]
        respond_to do |format|
          format.xlsx do
            render xlsx: "Rep_lot_by_winner_#{Time.now.to_s(:number)}", template: 'reports/other/lot_by_winer/main'
          end
        end
      end

      private

      def lot_by_winer_params
        params.require(:reports_other_lot_by_winer)
          .permit(:date_begin, :date_end, :format, :winners, gkpz_years: [], customers: [], organizers: [], directions: [])
          .merge(current_user_root_dept_id: current_user.root_dept_id)
      end

    end
  end
end

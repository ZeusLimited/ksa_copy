# frozen_string_literal: true

module Reports
  module Other
    class TermsViolationController < ApplicationController

      def options
        @options = Reports::Other::TermsViolation.new(
          date_begin: Date.new(Time.current.year, 1, 1),
          date_end: Time.now.to_date,
          gkpz_years: [Time.now.year]
        )
        render layout: false
      end

      def show
        @report = TermsViolation.new(start_form_params)

        request.format = start_form_params[:format]
        respond_to do |format|
          format.xlsx do
            render xlsx: "rep_terms_violation_#{Time.now.to_s(:number)}", template: 'reports/other/terms_violation/main'
          end
        end
      end

      private

      def start_form_params
        params.require(:reports_other_terms_violation)
              .permit(:date_begin, :date_end, :format, gkpz_years: [], consumers: [], organizers: [], tender_types: [],
                directions: [])
      end
    end
  end
end

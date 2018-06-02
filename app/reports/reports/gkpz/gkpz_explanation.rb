module Reports
  module Gkpz
    class GkpzExplanation < Reports::Base
      attr_accessor :gkpz_state

      def default_params
        @default_params ||= {
          begin_date: date_begin.to_date,
          end_date: date_end.to_date,
          date_gkpz_on_state: date_gkpz_on_state.to_date
        }.with_indifferent_access
      end

      def summary_rows
        @summary_rows ||= YAML.load(ERB.new(File.read("#{structures}/gkpz_explanation.yml")).result(binding))
      end

      def customer_names
        return if customers.blank?
        Department.where(id: customers).map(&:offname).join(', ')
      end

      def gkpz_row
        @gkpz_row ||= gkpz_sql_rows.first
      end

      def by_type_rows
        @by_type_rows ||= by_type_sql_rows
      end

      def high_rows
        @high_rows ||= high_sql_rows
      end

      def kpi_by_year
        gkpz_year = @gkpz_years ? @gkpz_years.last.to_i : Time.current.year
        @kpi_by_year ||= YAML.load(File.read("#{structures}/gkpz_explanation_kpi.yml"))
        @kpi_by_year[gkpz_year] || @kpi_by_year['default']
      end

      COLUMNS = {
        c1: { type: :string, style: :td, value: ->(r) { r['lot_num'] }, width: 15 },
        c2: { type: :string, style: :td, value: ->(r) { r['lot_name'] }, width: 45 },
        c3: { type: :string, style: :td, value: ->(r) { r['tender_type'] }, width: 10 },
        c4: { type: :float, style: :td_money, value: ->(r) { r['cost_nds'] }, width: 15 },
      }

      COLUMNS.each_pair do |ckey, cval|
        define_singleton_method(ckey) { |r| cval[:value].call(r) }
      end

      SUMMARY_COLUMNS = {
        c1: { type: :string, style: :td, value: ->(r) { r['name'] }, width: 15 },
        c2: { type: :string, style: :td, value: ->(r) { r['regulation_item_num'] }, width: 45 },
        c3: { type: :string, style: :td, value: ->(r) { r['kpi'] }, width: 10 },
        c4: { type: :float, style: :td_percent, value: ->(r) { r['fact'] }, width: 15 },
      }

      SUMMARY_COLUMNS.each_pair do |ckey, cval|
        define_singleton_method(ckey) { |r| cval[:value].call(r) }
      end

      private

      def total_reglament
        @gkpz_row['cost_nds_reg'] - @by_type_rows.select{ |t| t['tender_type_id'] == 10015 }.first['cost_nds']
      end
    end
  end
end

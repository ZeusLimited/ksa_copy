module Reports
  module Other
    class SummaryResult
      include ActiveModel::Model
      include ActiveRecord::Sanitization::ClassMethods

      attr_accessor :table_name
      attr_accessor :date_begin, :date_end, :gkpz_year, :customers, :organizers, :format
      attr_accessor :tender_types, :directions, :financing_sources, :subject_type
      attr_accessor :sql
      attr_accessor :current_user

      def connection
        ActiveRecord::Base.connection
      end

      def default_params
        @default_params ||= {
          protocol_end_date: date_end.to_date,
          gkpz_year: gkpz_year.to_i
        }.with_indifferent_access
      end

      def result_row(name, type, begin_date, end_date, etp = -1)
        params = default_params
          .merge(tender_type: type)
          .merge(etp_address: etp)
          .merge(name: name)
          .merge(begin_date: begin_date)
          .merge(end_date: end_date)
        connection.select_all(sanitize_sql([sql, params])).first
      end

      # types = [:date, :time, :float, :integer, :string, :boolean]

      COLUMNS = {
        c1: { type: :string, style: :td_right, value: ->(r) { r['name'] }, width: 30 },
        c2: { type: :integer, style: :td, value: ->(r) { r['gkpz_count'] }, width: 10, sum: true, sum_style: :sum },
        c3: { type: :float, style: :td_money, value: ->(r) { r['gkpz_cost'] }, width: 17, sum: true },
        c4: { type: :integer, style: :td, value: ->(r) { r['plan_count'] }, width: 10, sum: true, sum_style: :sum },
        c5: { type: :float, style: :td_money, value: ->(r) { r['plan_cost'] }, width: 17, sum: true },
        c6: { type: :integer, style: :td, value: ->(r) { r['anno_count'] }, width: 10, sum: true, sum_style: :sum },
        c7: { type: :float, style: :td_money, value: ->(r) { r['anno_cost'] }, width: 17, sum: true },
        c8: { type: :integer, style: :td, value: ->(r) { r['fact_count'] }, width: 10, sum: true, sum_style: :sum },
        c9: { type: :float, style: :td_money, value: ->(r) { r['fact_cost'] }, width: 17, sum: true },
        c10: { type: :float, style: :td_money, value: ->(r) { r['winner_cost'] }, width: 17, sum: true },
        c11: {
          type: :float, style: :td_percent, value: ->(r) { c2(r) == 0 ? 0 : c8(r) / c2(r).try(:to_f) }, width: 10,
          sum: true, sum_style: :sum_percent
        },
        c12: {
          type: :float, style: :td_percent, value: ->(r) { c3(r) == 0 ? 0 : c10(r) / c3(r) }, width: 10,
          sum: true, sum_style: :sum_percent
        },
        c13: {
          type: :float, style: :td_percent, value: ->(r) { c4(r) == 0 ? 0 : c8(r) / c4(r).try(:to_f) }, width: 10,
          sum: true, sum_style: :sum_percent
        },
        c14: {
          type: :float, style: :td_percent, value: ->(r) { c5(r) == 0 ? 0 : c10(r) / c5(r) }, width: 10,
          sum: true, sum_style: :sum_percent
        },
        c15: { type: :float, style: :td_money, value: ->(r) { (c9(r) || 0) - (c10(r) || 0) }, width: 17, sum: true },
        c16: {
          type: :float, style: :td_percent, value: ->(r) { c9(r) == 0 ? 0 : (c9(r) - c10(r)) / c9(r) }, width: 10,
          sum: true, sum_style: :sum_percent
        }
      }

      COLUMNS.each_pair do |ckey, cval|
        define_singleton_method(ckey) { |r| cval[:value].call(r) }
      end
    end
  end
end

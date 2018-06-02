module Reports
  module Reglament
    class SmeTable < Reports::Base
      def default_params
        @default_params ||= {
          begin_date: date_begin.to_date,
          end_date: date_end.to_date,
          gkpz_year: gkpz_year.to_i,
        }.with_indifferent_access
      end

      # types = [:date, :time, :float, :integer, :string, :boolean]

      COLUMNS = {
        c1: { type: :string, style: :td, value: ->(r) { r['name'] }, width: 40 },
        c2: {
          type: :float, style: :td_money, value: ->(r) { to_thousand(r['contract_cost_nds']) }, sum: true, width: 30
        },
        c3: {
          type: :float, style: :td_money, value: ->(r) { to_thousand(r['sme_contract_cost_nds']) }, width: 30,
          sum: true
        },
        c4: {
          type: :float, style: :td_percent, value: ->(r) { c2(r).zero? ? nil : c3(r) / c2(r) }, width: 30,
          sum: true, sum_value: ->(g) { g["c2_total"].zero? ? nil : g["c3_total"] / g["c2_total"] },
          sum_style: :sum_percent
        },
        c5: {
          type: :float, style: :td_money, value: ->(r) { to_thousand(r['subsme_contract_cost_nds']) }, width: 30,
          sum: true
        },
        c6: {
          type: :float, style: :td_percent, value: ->(r) { c2(r).zero? ? nil : (c5(r) || 0) / c2(r) }, width: 30,
          sum: true, sum_value: ->(g) { g["c2_total"].zero? ? nil : g["c5_total"] / g["c2_total"] },
          sum_style: :sum_percent
        },
        c7: {
          type: :float, style: :td_money, value: ->(r) { to_thousand(r['all_contract_cost_nds']) }, sum: true,
          width: 30
        },
        c8: {
          type: :float, style: :td_percent, value: ->(r) { c2(r).zero? ? nil : (c7(r) || 0) / c2(r) }, width: 30,
          sum: true, sum_value: ->(g) { g["c2_total"].zero? ? nil : g["c7_total"] / g["c2_total"] },
          sum_style: :sum_percent
        },
      }

      COLUMNS.each_pair do |ckey, cval|
        define_singleton_method(ckey) { |r| cval[:value].call(r) }
      end
    end
  end
end

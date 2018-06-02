module Reports
  module Other
    class OverdueContract < Reports::Base
      def default_params
        @default_params ||= {
          begin_date: date_begin.to_date,
          end_date: date_end.to_date,
          gkpz_year: gkpz_year.to_i
        }.with_indifferent_access
      end

      # types = [:date, :time, :float, :integer, :string, :boolean]

      COLUMNS = {
        c1: { type: :string, style: :td_right, value: ->(r) { r['lot_num'] }, width: 10 },
        c2: { type: :string, style: :td, value: ->(r) { r['lot_name'].strip }, width: 50 },
        c3: { type: :string, style: :td, value: ->(r) { r['tender_type_name'] }, width: 15 },
        c4: { type: :float, style: :td_money, value: ->(r) { r['cost'] }, width: 15 },
        c5: { type: :float, style: :td_money, no_merge: true, value: ->(r) { r['winner_cost'] }, width: 15 },
        c6: { type: :string, style: :td, no_merge: true, value: ->(r) { r['winner_name'] }, width: 30 },
        c7: { type: :date, style: :td_date, value: ->(r) { r['wp_confirm_date'].try(:to_date) }, width: 15 },
        c8: { type: :date, style: :td_date, value: ->(r) { r['wp_confirm_date'].try(:to_date) }, width: 15 },
        c9: { type: :integer, style: :td, value: ->(r) { c8(r) - c7(r) }, width: 15 },
        c10: { type: :date, style: :td_date, value: ->(r) { r['contract_confirm_date'].try(:to_date) }, width: 15 },
        c11: { type: :integer, style: :td, value: ->(r) { r['delta'] }, width: 15 },
        c12: { type: :string, style: :td, value: ->(r) { r['non_contract_reason'] }, width: 60 }
      }

      COLUMNS.each_pair do |ckey, cval|
        define_singleton_method(ckey) { |r| cval[:value].call(r) }
      end

      PIVOT_COLUMNS = {
        pc1: { type: :string, style: :td, value: ->(r) { r['tender_type_name'] }, width: 15 },
        pc2: { type: :integer, style: :td, value: ->(r) { r['min_delta'] }, width: 20 },
        pc3: { type: :string, style: :td_right, value: ->(r) { r['min_tender_num'] }, width: 20 },
        pc4: { type: :integer, style: :td, value: ->(r) { r['max_delta'] }, width: 20 },
        pc5: { type: :string, style: :td_right, value: ->(r) { r['max_tender_num'] }, width: 20 },
        pc6: { type: :float, style: :td_money, value: ->(r) { r['avg_delta'] }, width: 20 }
      }

      PIVOT_COLUMNS.each_pair do |ckey, cval|
        define_singleton_method(ckey) { |r| cval[:value].call(r) }
      end
    end
  end
end

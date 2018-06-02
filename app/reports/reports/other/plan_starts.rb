module Reports
  module Other
    class PlanStarts < Reports::Base
      def default_params
        @default_params ||= {
          begin_date: date_begin.to_date,
          end_date: date_end.to_date,
          gkpz_year: gkpz_year.to_i
        }.with_indifferent_access
      end

      # types = [:date, :time, :float, :integer, :string, :boolean]

      COLUMNS = {
        c1: { type: :string, style: :td, value: ->(r) { r['lot_name'] }, width: 60 },
        c2: {
          type: :string, style: :td, value: ->(r) { [r['num_tender'], r['num_lot']].join('.') }, width: 25
        },
        c3: { type: :float, style: :td_money, value: ->(r) { r['cost'] }, width: 25 },
        c4: { type: :date, style: :td_date, value: ->(r) { r['announce_date'].try(:to_date) }, width: 15 },
        c5: { type: :date, style: :td_date, value: ->(r) { r['order_date'].try(:to_date) }, width: 15 },
        c6: { type: :string, style: :td, value: ->(r) { r['tender_type_name'] }, width: 20 },
        c7: { type: :string, style: :td, value: ->(r) { r['is_etp'] }, width: 15 },
        c8: { type: :string, style: :td_money, value: ->(r) { r['organizer_name'] }, width: 30 },
        c9: { type: :string, style: :td, value: ->(r) { r['commission_type_name'] }, width: 15 },
        c10: { type: :string, style: :td_money, value: ->(r) { r['monitor_service_name'] }, width: 30 },
        c11: { type: :date, style: :td_date, value: ->(r) { r['delivery_date_begin'].try(:to_date) }, width: 15 },
        c12: { type: :date, style: :td_date, value: ->(r) { r['delivery_date_end'].try(:to_date) }, width: 15 },
        c13: { type: :string, style: :td_money, value: ->(r) { r['contractors'] }, width: 30 },
        c14: { type: :string, style: :td, value: ->(r) { r['bp_items'] }, width: 40 },
        c15: { type: :string, style: :td, value: ->(r) { r['curator'] }, width: 25 },
        c16: { type: :string, style: :td, value: ->(r) { r['tech_curator'] }, width: 25 }
      }

      COLUMNS.each_pair do |ckey, cval|
        define_singleton_method(ckey) { |r| cval[:value].call(r) }
      end
    end
  end
end

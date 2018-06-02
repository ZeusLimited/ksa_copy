module Reports
  module Other
    class TenderBidders < Reports::Base
      attr_accessor :contractors

      def default_params
        @default_params ||= {
          begin_date: date_begin.to_date,
          end_date: date_end.to_date
        }.with_indifferent_access
      end

      COLUMNS = {
        # c0: { type: :string, value: ->(r) { r['contractor_name'] }, style: :td },
        c1: { type: :string, value: ->(r) { r['customer_name'] }, style: :td, width: 30 },
        c2: { type: :string, value: ->(r) { r['lot_num'] }, style: :td, width: 15 },
        c3: { type: :date, value: ->(r) { r['confirm_date'].try(:to_date) }, style: :td_date, width: 15 },
        c4: { type: :string, value: ->(r) { r['lot_name'] }, style: :td, width: 60 },
        c5: { type: :string, value: ->(r) { r['is_winner'] }, style: :td, width: 12 },
        c6: { type: :float, value: ->(r) { r['final_cost'] }, style: :td_money, width: 20 },
        c7: { type: :float, value: ->(r) { r['winner_cost'] }, style: :td_money, width: 20 },
        c8: { type: :string, value: ->(r) { r['tender_type_name'] }, style: :td, width: 15 },
        c10: { type: :string, value: ->(r) { r['organizer_name'] }, style: :td, width: 30 }
      }

      COLUMNS.each_pair do |ckey, cval|
        define_singleton_method(ckey) { |r| cval[:value].call(r) }
      end
    end
  end
end

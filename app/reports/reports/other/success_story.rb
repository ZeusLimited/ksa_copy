module Reports
  module Other
    class SuccessStory < Reports::Base
      attr_accessor :lot_id

      def default_params
        @default_params ||= {
          begin_date: date_begin.to_date,
          end_date: date_end.to_date,
          lot_id: lot_id.try(:to_i)
        }.with_indifferent_access
      end

      COLUMNS = {
        c1: { type: :float, value: ->(r) { r['rn'] }, style: :td_center, width: 5 },
        c2: { type: :string, value: ->(r) { r['customer'] }, style: :td, width: 50 },
        c3: { type: :string, value: ->(r) { r['contractor'] }, style: :td, width: 50 },
        c4: { type: :string, value: ->(r) { r['lot_name'] }, style: :td, width: 50, detail: true },
        c5: { type: :string, value: ->(r) { r['contact_person'] }, style: :td, width: 50 },
        c6: { type: :string, style: :td, width: 50 },
        c7: { type: :string, style: :td, width: 30 },
        c8: { type: :string, style: :td, width: 30 }
      }

      COLUMNS_DETAILED = {
        c1: { type: :string, value: ->(r) { r['gkpz_num'] }, style: :td_center, width: 5 },
        c2: { type: :string, value: ->(r) { r['lot_name'] }, style: :td, width: 50 },
        c3: { type: :string, value: ->(r) { r['customer'] }, style: :td, width: 50 },
        c4: { type: :string, value: ->(r) { r['contract_num'] }, style: :td, width: 50 },
        c5: { type: :string, value: ->(r) { r['contract_date'] }, style: :td, width: 50, detail: true },
        c6: { type: :string, value: ->(r) { r['contractor'] }, style: :td, width: 50 },
        c7: { type: :float, value: ->(r) { r['contract_sum'] }, style: :td_center, width: 5, money: true }
      }

      COLUMNS.each_pair do |ckey, cval|
        define_singleton_method(ckey) { |r| cval[:value].call(r) }
      end
    end
  end
end

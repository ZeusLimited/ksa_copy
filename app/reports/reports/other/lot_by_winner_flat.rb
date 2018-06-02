module Reports
  module Other
    class LotByWinnerFlat < Reports::Base

      attr_accessor :winners

      def self.parents_tree_by_id(dept_id)
        @parents_tree_by_id ||= Hash.new do |h, key|
          h[key] = Department.find(key).path.pluck(:name).join(' --> ')
        end
        @parents_tree_by_id[dept_id]
      end

      COLUMNS = {
        c1: { type: :string, value: ->(r) { r['customer'] && parents_tree_by_id(r['customer']) }, style: :td, width: 50 },
        c2: { type: :string, value: ->(r) { r['num_tender'] }, style: :td, width: 15 },
        c3: { type: :float, value: ->(r) { r['gkpz_num'] }, style: :td, width: 15 },
        c4: { type: :string, value: ->(r) { r['lot_name'] }, style: :td, width: 50 },
        c5: { type: :float, value: ->(r) { r['final_cost'] }, style: :td_money, width: 15 },
        c6: { type: :float, value: ->(r) { r['contract_cost'] }, style: :td_money, width: 15 },
        c7: { type: :float, value: ->(r) { r['contract_cost_nds'] }, style: :td_money, width: 15 },
        c8: { type: :string, value: ->(r) { r['contract_num'] }, style: :td, width: 15 },
        c9: { type: :string, value: ->(r) { r['contractor_fullname'] }, style: :td, width: 50 },
        c10: { type: :string, value: ->(r) { r['organizer'] && parents_tree_by_id(r['organizer']) }, style: :td, width: 30 },
        c11: { type: :string, value: ->(r) { r['qtype_name'] }, style: :td, width: 30 },
        c12: { type: :string, value: ->(r) { r['direction_name'] }, style: :td, width: 25 },
        c13: { type: :date, value: ->(r) { r['bid_date'].try(:to_date) }, style: :td_date, width: 15 },
        c14: { type: :date, value: ->(r) { r['protocol_confirm_date'].try(:to_date) }, style: :td_date, width: 15 },
        c15: { type: :string, value: ->(r) { r['bp_item'] }, style: :td, width: 30 }
      }

      COLUMNS.each_pair do |ckey, cval|
        define_singleton_method(ckey) { |r| cval[:value].call(r) }
      end
    end
  end
end

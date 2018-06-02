module Reports
  module Reglament
    class HundredMillionsTenders < Reports::Base
      attr_accessor :vz, :hundred_millions, :contractors, :nomenclature

      def default_params
        @default_params ||= {
          begin_date: date_begin.to_date,
          end_date: date_end.to_date,
          subj_type: -1,
          vz: vz.to_i,
          hundred_millions: hundred_millions.to_i
        }.with_indifferent_access
      end

      COLUMNS = {
        c1: { type: :string, style: :td, value: ->(r) { r['rn'] }, width: 20 },
        c1_1: { type: :string, style: :td, value: ->(r) { r['gkpz_year'] }, width: 20 },
        c2: { type: :string, style: :td, value: ->(r) { r['lot_num'] }, width: 20 },
        c3: { type: :string, style: :td, value: ->(r) { r['lots_cnt'] }, width: 20 },
        c4: { type: :string, style: :td, value: ->(r) { r['root_customer_name'] }, width: 20 },
        c5: { type: :string, style: :td, value: ->(r) { r['is_hundred_millions'] }, width: 20 },
        c6: { type: :string, style: :td, value: ->(r) { r['lot_name'] }, width: 40 },
        c7: { type: :string, style: :td, value: ->(r) { r['lot_state'] }, width: 20 },
        c8: { type: :string, style: :td, value: ->(r) { r['plan_tender_type'] }, width: 20 },
        c9: { type: :string, style: :td, value: ->(r) { r['commission_type_name'] }, width: 20 },
        c10: { type: :string, style: :td, value: ->(r) { r['fact_tender_type'] }, width: 20 },
        c11: { type: :string, style: :td, value: ->(r) { r['etp'] }, width: 20 },
        c12: { type: :float, style: :td_money, value: ->(r) { r['gkpz_cost'] }, width: 20 },
        c13: { type: :float, style: :td_money, value: ->(r) { r['gkpz_cost_nds'] }, width: 20 },
        c13_1: { type: :string, style: :td, value: ->(_) { '' }, width: 20 },
        c13_2: { type: :string, style: :td, value: ->(_) { '' }, width: 20 },
        c13_3: { type: :string, style: :td, value: ->(_) { '' }, width: 20 },
        c13_4: { type: :string, style: :td, value: ->(_) { '' }, width: 20 },
        c13_5: { type: :string, style: :td, value: ->(_) { '' }, width: 20 },
        c14: { type: :string, style: :td_date, value: ->(r) { r['gkpz_announce_date'].try(:to_date) }, width: 20 },
        c15: { type: :string, style: :td_date, formula: ->(_, i) { "=T#{i}-35" }, width: 20 },
        c16: { type: :string, style: :td, value: ->(r) { r['empty'] }, width: 20 },
        c17: { type: :string, style: :td_date, value: ->(r) { r['fact_announce_date'].try(:to_date) }, width: 20 },
        c18: { type: :string, style: :td_date, value: ->(r) { r['gkpz_open_date'].try(:getlocal, Time.zone.utc_offset).try(:to_date) }, width: 20 },
        c19: { type: :string, style: :td_date, value: ->(r) { r['fact_open_date'].try(:getlocal, Time.zone.utc_offset).try(:to_date) }, width: 20 },
        c20: { type: :string, style: :td, value: ->(r) { c19(r) ? r['cnt_offers'] : 0 }, width: 20 },
        c21: { type: :string, style: :td, value: ->(r) { r['bidder_name'] }, width: 20, no_merge: true },
        c22: { type: :float, style: :td_money, value: ->(r) { r['bid_cost'] }, width: 20, no_merge: true },
        c23: { type: :float, style: :td_money, value: ->(r) { r['bid_cost_nds'] }, width: 20, no_merge: true },
        c24: { type: :string, style: :td, value: ->(r) { r['offer_receive'] }, width: 20, no_merge: true },
        c25: { type: :float, style: :td_money, value: ->(r) { r['rebid_cost'] }, width: 20, no_merge: true },
        c26: { type: :float, style: :td_money, value: ->(r) { r['rebid_cost_nds'] }, width: 20, no_merge: true },
        c27: { type: :string, style: :td, value: ->(r) { r['winner'] }, width: 20 },
        c28: { type: :float, style: :td_money, value: ->(r) { r['winner_cost_plan_ratio'] }, width: 20 },
        c29: { type: :float, style: :td_money, value: ->(r) { r['winner_cost_plan_ratio_nds'] }, width: 20 },
        c30: { type: :string, style: :td_money, formula: ->(r, i) { r['winner'] ? "=M#{i}-AH#{i}" : '' }, width: 20 },
        c31: { type: :string, style: :td_money, formula: ->(r, i) { r['winner'] ? "=N#{i}-AI#{i}" : '' }, width: 20 },
        c32: { type: :string, style: :td_percent, formula: ->(r, i) { r['winner'] ? "=AJ#{i}/M#{i}" : '' }, width: 20 },
        c33: { type: :string, style: :td, value: ->(r) { r['responsible'] }, width: 20 },
        c34: { type: :string, style: :td_date, value: ->(r) { r['winner_protocol_date'].try(:to_date) }, width: 20 },
        c35: { type: :string, style: :td, value: ->(r) { r['empty'] }, width: 20 },
        c36: { type: :string, style: :td, value: ->(r) { r['empty'] }, width: 20 },
        c37: { type: :string, style: :td, value: ->(r) { r['empty'] }, width: 20 },
        c38: { type: :string, style: :td, value: ->(r) { r['org_name'] }, width: 20 },
        c39: { type: :string, style: :td, value: ->(r) { r['note'] }, width: 20 },
        c40: { type: :string, style: :td, value: ->(r) { r['direction'] }, width: 20 },
        c41: { type: :string, style: :td, value: ->(r) { r['pl_status'] }, width: 20 }
      }

      COLUMNS_PART_3 = {
        c1: { type: :string, style: :td, value: ->(r) { r['rn'] }, width: 20 },
        c1_1: { type: :string, style: :td, value: ->(r) { r['gkpz_year'] }, width: 20 },
        c2: { type: :string, style: :td, value: ->(r) { r['lot_num'] }, width: 20 },
        c3: { type: :string, style: :td, value: ->(r) { r['lots_cnt'] }, width: 20 },
        c4: { type: :string, style: :td, value: ->(r) { r['root_customer_name'] }, width: 20 },
        c5: { type: :string, style: :td, value: ->(r) { r['is_hundred_millions'] }, width: 20 },
        c6: { type: :string, style: :td, value: ->(r) { r['lot_name'] }, width: 40 },
        c7: { type: :string, style: :td, value: ->(r) { r['lot_state'] }, width: 20 },
        c8: { type: :string, style: :td, value: ->(r) { r['plan_tender_type'] }, width: 20 },
        c9: { type: :string, style: :td, value: ->(r) { r['commission_type_name'] }, width: 20 },
        c10: { type: :string, style: :td, value: ->(r) { r['fact_tender_type'] }, width: 20 },
        c11: { type: :string, style: :td, value: ->(r) { r['etp'] }, width: 20 },
        c12: { type: :float, style: :td_money, value: ->(r) { r['gkpz_cost'] }, width: 20 },
        c13: { type: :float, style: :td_money, value: ->(r) { r['gkpz_cost_nds'] }, width: 20 },
        c13_1: { type: :string, style: :td, value: ->(r) { '' }, width: 20 },
        c13_2: { type: :string, style: :td, value: ->(r) { '' }, width: 20 },
        c13_3: { type: :string, style: :td, value: ->(r) { '' }, width: 20 },
        c13_4: { type: :string, style: :td, value: ->(r) { '' }, width: 20 },
        c13_5: { type: :string, style: :td, value: ->(r) { '' }, width: 20 },
        c14: { type: :string, style: :td_date, value: ->(r) { r['gkpz_announce_date'].try(:to_date) }, width: 20 },
        c15: { type: :string, style: :td_date, value: ->(r) { r['empty'] }, width: 20 },
        c16: { type: :string, style: :td, value: ->(r) { r['empty'] }, width: 20 },
        c17: { type: :string, style: :td_date, value: ->(r) { r['fact_announce_date'].try(:to_date) }, width: 20 },
        c18: { type: :string, style: :td_date, value: ->(r) { r['gkpz_open_date'].try(:to_date) }, width: 20 },
        c19: { type: :string, style: :td_date, value: ->(r) { r['fact_open_date'].try(:to_date) }, width: 20 },
        c20: { type: :string, style: :td, value: ->(r) { r['cnt_offers'] }, width: 20 },
        c21: { type: :string, style: :td, value: ->(r) { r['bidder_name'] }, width: 20, no_merge: true },
        c22: { type: :float, style: :td_money, value: ->(r) { r['bid_cost'] }, width: 20, no_merge: true },
        c23: { type: :float, style: :td_money, value: ->(r) { r['bid_cost_nds'] }, width: 20, no_merge: true },
        c24: { type: :string, style: :td, value: ->(r) { r['offer_receive'] }, width: 20, no_merge: true },
        c25: { type: :float, style: :td_money, value: ->(r) { r['rebid_cost'] }, width: 20, no_merge: true },
        c26: { type: :float, style: :td_money, value: ->(r) { r['rebid_cost_nds'] }, width: 20, no_merge: true },
        c27: { type: :string, style: :td, value: ->(r) { r['winner'] }, width: 20 },
        c28: { type: :float, style: :td_money, value: ->(r) { r['winner_cost_plan_ratio'] }, width: 20 },
        c29: { type: :float, style: :td_money, value: ->(r) { r['winner_cost_plan_ratio_nds'] }, width: 20 },
        c30: { type: :string, style: :td_money, value: ->(r) { r['empty'] }, width: 20 },
        c31: { type: :string, style: :td_money, value: ->(r) { r['empty'] }, width: 20 },
        c32: { type: :string, style: :td_percent, value: ->(r) { r['empty'] }, width: 20 },
        c33: { type: :string, style: :td, value: ->(r) { r['empty'] }, width: 20 },
        c34: { type: :string, style: :td_date, value: ->(r) { r['empty'] }, width: 20 },
        c35: { type: :string, style: :td, value: ->(r) { r['empty'] }, width: 20 },
        c36: { type: :string, style: :td, value: ->(r) { r['empty'] }, width: 20 },
        c37: { type: :string, style: :td, value: ->(r) { r['empty'] }, width: 20 },
        c38: { type: :string, style: :td, value: ->(r) { r['org_name'] }, width: 20 },
        c39: { type: :string, style: :td, value: ->(r) { r['empty'] }, width: 20 },
        c40: { type: :string, style: :td, value: ->(r) { r['direction'] }, width: 20 },
        c41: { type: :string, style: :td, value: ->(r) { r['pl_status'] }, width: 20 }
      }

      COLUMNS.each_pair do |ckey, cval|
        define_singleton_method(ckey) { |r| cval[:value].call(r) }
      end
    end
  end
end

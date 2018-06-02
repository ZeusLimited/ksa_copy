module Reports
  module Other
    class TendersEfficiencyV2 < Reports::Base
      def default_params
        @default_params ||= {
          begin_date: date_begin.to_date,
          end_date: date_end.to_date,
          gkpz_years: gkpz_years
        }.with_indifferent_access
      end

      COLUMNS = {
        c1: { type: :integer, style: :td, width: 5 },
        c2: { type: :string, style: :td_right, value: ->(r) { r['lot_num'] }, width: 15 },
        c3: { type: :string, style: :td, value: ->(r) { r['lot_name'].strip }, width: 60 },
        c4: { type: :string, style: :td, value: ->(r) { r['lot_state'] }, width: 15 },
        c5_1: { type: :string, style: :td, value: ->(r) { r['customer_name'] }, width: 15 },
        c5_2: { type: :string, style: :td, value: ->(r) { r['org_name'] }, width: 40 },
        c6: { type: :string, style: :td, value: ->(r) { r['ctype_name'] }, width: 15 },
        c7: {
          type: :float, style: :td_money, value: ->(r) { r['gkpz_cost_nds'] }, sum: true,
          width: 20
        },
        c7_1: { type: :string, style: :td, value: ->(r) { r['sme_type_name'] }, width: 30 },
        c8: { type: :float, style: :td_money, value: ->(r) { r['s_cost_nds'] }, sum: true, width: 20 },
        c9: { type: :string, style: :td, value: ->(r) { r['gkpz_ttype_name'] }, width: 15 },
        c10: { type: :string, style: :td, value: ->(r) { r['fact_ttype_name'] }, width: 15 },
        c11: { type: :string, style: :td, value: ->(r) { r['fact_ei'] }, width: 15 },
        c12: {
          type: :date, style: :td_date, value: ->(r) { r['gkpz_announce_date'].try(:to_date) },
          width: 15
        },
        c13: {
          type: :date, style: :td_date, value: ->(r) { r['fact_announce_date'].try(:to_date) }, width: 15
        },
        c14: {
          type: :date, style: :td_date, value: ->(r) { r['op_open_date'].try(:getlocal, Time.zone.utc_offset).try(:to_date) }, width: 15
        },
        c15: { type: :integer, style: :td, value: ->(r) { r['cnt_offers'] }, width: 15 },
        c16: { type: :string, style: :td, no_merge: true, value: ->(r) { r['contr_name'] }, width: 60 },
        c17: {
          type: :float, style: :td_money, no_merge: true, value: ->(r) { r['bid_cost_nds'] }, width: 20
        },
        c18: { type: :string, style: :td, no_merge: true, value: ->(r) { r['bid_reject_name'] }, width: 60 },
        c19_0: { type: :float, style: :td_money, value: ->(r) { r['average_cost_without_nds'] }, sum: true, width: 20 },
        c19: { type: :float, style: :td_money, value: ->(r) { r['average_cost'] }, sum: true, width: 20 },
        c19_1: { type: :string, style: :td_center, value: ->(r) { r['rebid'] ? '+' : '-' }, width: 15 },
        c19_2: {
          type: :float, style: :td_money, no_merge: true, value: ->(r) { r['bid_final_cost'] if r['rebid'] },
          width: 20
        },
        c19_3: {
          type: :float, style: :td_money, no_merge: true, value: ->(r) { r['bid_final_cost_nds'] if r['rebid'] },
          width: 20
        },
        c20: {
          type: :string, style: :td, no_merge: true, value: ->(r) { r['bid_winner_name'] }, width: 60
        },
        c21_0: {
          type: :float, style: :td_money, no_merge: true, value: ->(r) { r['winner_cost'] }, sum: true, width: 20
        },
        c21: {
          type: :float, style: :td_money, no_merge: true, value: ->(r) { r['winner_cost_nds'] }, sum: true, width: 20
        },
        c22: { type: :date, style: :td_date, value: ->(r) { r['wp_confirm_date'].try(:to_date) }, width: 15 },
        c23: { type: :float, style: :td_money, value: ->(r) { (c7(r) || 0) - (c21(r) || 0) }, sum: true, width: 20 },
        c24: {
          type: :float, style: :td_percent, value: ->(r) { c7(r).to_f == 0 ? nil : c23(r) / c7(r).to_f }, width: 15,
          sum: true, sum_value: ->(g) { g["c7_total"] == 0 ? nil : g["c23_total"] / g["c7_total"].to_f },
          sum_style: :sum_percent, persent_formula: { numerator: 25, denomenator: 6 }
        },
        c25: { type: :float, style: :td_money, value: ->(r) { c8(r) - (c21(r) || 0) }, sum: true, width: 20 },
        c26: {
          type: :float, style: :td_percent, value: ->(r) { c8(r) == 0 ? nil : c25(r) / c8(r).to_f }, width: 15,
          sum: true, sum_value: ->(g) { g["c8_total"] == 0 ? nil : g["c25_total"] / g["c8_total"].to_f },
          sum_style: :sum_percent, persent_formula: { numerator: 27, denomenator: 8 }
        },
        c27: { type: :float, style: :td_money, value: ->(r) { (c19(r) || 0) - (c21(r) || 0) }, sum: true, width: 20 },
        c28: {
          type: :float, style: :td_percent, value: ->(r) { c19(r) == 0 ? nil : c27(r) / c19(r).to_f }, width: 15,
          sum: true, sum_value: ->(g) { g["c19_total"] == 0 ? nil : g["c27_total"] / g["c19_total"].to_f },
          sum_style: :sum_percent, persent_formula: { numerator: 29, denomenator: 19 }
        },
        c29: { type: :string, style: :td, value: ->(r) { r['contract_status'] }, width: 30 },
        c30: { type: :date, style: :td_date, value: ->(r) { r['plan_contract_date'].try(:to_date) }, width: 15 },
        c31: { type: :date, style: :td_date, value: ->(r) { r['contract_confirm_date'].try(:to_date) }, width: 15 },
        c32: { type: :float, style: :td_money, value: ->(r) { r['contract_spec_cost_nds'] }, sum: true, width: 20 },
        c33: { type: :string, style: :td, value: ->(r) { r['is_sme'] }, width: 30 },
        c34: { type: :float, style: :td_money, value: ->(r) { c33(r) ? c32(r) : nil }, sum: true, width: 30 },
        c35: {
          type: :float, style: :td_percent, value: ->(r) { c33(r) ? 1.0 : nil }, width: 30,
          sum: true, sum_value: ->(g) { g["c32_total"] == 0 ? nil : g["c34_total"] / g["c32_total"].to_f },
          sum_style: :sum_percent, persent_formula: { numerator: 36, denomenator: 34 }
        },
        c36: { type: :string, style: :td, value: ->(r) { c37(r) > 0 ? 'МСП' : nil }, width: 30 },
        c37: { type: :integer, style: :td, value: ->(r) { r['sub_cnt'] }, width: 30 },
        c38: { type: :float, style: :td_money, value: ->(r) { r['sub_cost_nds'] || 0 }, sum: true, width: 30 },
        c39: {
          type: :float, style: :td_percent, value: ->(r) { c32(r) && c32(r) != 0 ? c38(r) / c32(r).to_f : nil },
          width: 30,
          sum: true, sum_value: ->(g) { g["c32_total"] == 0 ? nil : g["c38_total"] / g["c32_total"].to_f },
          sum_style: :sum_percent, persent_formula: { numerator: 40, denomenator: 34 }
        },
        c40: {
          type: :float, style: :td_money,
          value: (lambda do |r|
            return c34(r) if c33(r) == 'МСП'
            return c38(r) if c36(r) == 'МСП'
            0
          end), sum: true, width: 30
        },
        c41: {
          type: :float, style: :td_percent, value: ->(r) { c32(r) && c32(r) != 0 ? c40(r) / c32(r).to_f : nil },
          width: 30,
          sum: true, sum_value: ->(g) { g["c32_total"] == 0 ? nil : g["c40_total"] / g["c32_total"].to_f },
          sum_style: :sum_percent, persent_formula: { numerator: 42, denomenator: 34 }
        },
        c42: { type: :string, style: :td, value: ->(r) { r['life_cycle'] }, width: 10 },
        c43: { type: :string, style: :td, value: ->(r) { r['note'] }, width: 20 },
        c44: { type: :date, style: :td_date, value: ->(r) { r['order_receiving_date'].try(:to_date) }, width: 20 },
        c45: { type: :date, style: :td_date, value: ->(r) { r['order_agreement_date'].try(:to_date) }, width: 20 },
        c46: { type: :string, style: :td, value: ->(r) { r['is_start_violation'] }, width: 20 },
        c47: { type: :string, style: :td, value: ->(r) { r['start_violation_reason'] }, width: 20 },
        c48: { type: :string, style: :td, value: ->(r) { r['responsible_user'] }, width: 20 }
      }.freeze

      COLUMNS.each_pair do |ckey, cval|
        define_singleton_method(ckey) { |r| cval[:value].call(r) }
      end
    end
  end
end

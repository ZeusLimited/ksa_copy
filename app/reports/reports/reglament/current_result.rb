module Reports
  module Reglament
    class CurrentResult < Reports::Base
      attr_accessor :consumers

      def groups
        @groups ||= YAML.load(ERB.new(File.read("#{structures}/current_result.yml")).result(binding))
      end

      def default_params
        @default_params ||= {
          begin_date: date_begin.to_date,
          end_date: date_end.to_date,
          gkpz_year: gkpz_year.to_i
        }.with_indifferent_access
      end

      def part1_rows(filter)
        part1_sql_rows.select do |r|
          filter.all? { |k, v| Array(v).include?(r[k.to_s]) }
        end.sort_by { |r| r['sort_order'] }
      end

      def part2_rows(filter)
        part2_sql_rows.select do |r|
          filter.all? { |k, v| Array(v).include?(r[k.to_s]) }
        end.sort_by { |r| r['sort_order'] }
      end

      def part3_rows(filter)
        part3_sql_rows.select do |r|
          filter.all? { |k, v| Array(v).include?(r[k.to_s]) }
        end.sort_by { |r| r['sort_order'] }
      end

      def self.plan_contract_date(confirm_date, contract_period, contract_period_type)
        contract_period ? contract_period.business_days.after(confirm_date) : contract_period.after(confirm_date)
      end

      # types = [:date, :time, :float, :integer, :string, :boolean]

      COLUMNS = {
        c1: { type: :integer, style: :td, width: 05, part2: true, part3: true },
        c2: { type: :string, style: :td_right, value: ->(r) { r['lot_num'] }, width: 15, part2: true, part3: true },
        c3: { type: :string, style: :td, value: ->(r) { r['lot_name'].strip }, width: 60, part2: true, part3: true },
        c4: { type: :string, style: :td, value: ->(r) { r['lot_state'] }, width: 15, part2: true, part3: true },
        c5: { type: :string, style: :td, value: ->(r) { r['org_name'] }, width: 40, part2: true, part3: true },
        c6: { type: :string, style: :td, value: ->(r) { r['consumer'] }, width: 20, sum_style: :sum_money },
        c7: { type: :string, style: :td, value: ->(r) { r['ctype_name'] }, width: 15, part2: true, part3: true },
        c8: {
          type: :float, style: :td_money, value: ->(r) { r['gkpz_cost_nds'] }, sum: true,
          width: 20, part2: true, part3: true
        },
        c8_1: { type: :string, style: :td, value: ->(r) { r['sme_type_name'] }, width: 30, part2: true, part3: true },
        c9: { type: :float, style: :td_money, value: ->(r) { r['s_cost_nds'] }, sum: true, width: 20, part2: true },
        c10: { type: :string, style: :td, value: ->(r) { r['gkpz_ttype_name'] }, width: 15, part2: true, part3: true },
        c11: { type: :string, style: :td, value: ->(r) { r['fact_ttype_name'] }, width: 15, part2: true },
        c12: { type: :string, style: :td, value: ->(r) { r['fact_ei'] }, width: 15, part2: true },
        c13: {
          type: :date, style: :td_date, value: ->(r) { r['gkpz_announce_date'].try(:to_date) },
          width: 15, part2: true, part3: true
        },
        c14: {
          type: :date, style: :td_date, value: ->(r) { r['fact_announce_date'].try(:to_date) }, width: 15, part2: true
        },
        c15: {
          type: :date, style: :td_date, value: ->(r) { r['op_open_date'].try(:getlocal, Time.zone.utc_offset).try(:to_date) }, width: 15,
          part2: true
        },
        c16: { type: :integer, style: :td, value: ->(r) { r['cnt_offers'] }, width: 15 },
        c17: { type: :string, style: :td, no_merge: true, value: ->(r) { r['contr_name'] }, width: 60 },
        c18: {
          type: :float, style: :td_money, no_merge: true, value: ->(r) { r['bid_cost_nds'] }, width: 20
        },
        c19: { type: :string, style: :td, no_merge: true, value: ->(r) { r['bid_reject_name'] }, width: 60 },
        c20: { type: :float, style: :td_money, value: ->(r) { r['average_cost'] }, sum: true, width: 20 },
        c20_1: { type: :string, style: :td_center, value: ->(r) { r['rebid'] ? '+' : '-' }, width: 15 },
        c20_2: {
          type: :float, style: :td_money, no_merge: true, value: ->(r) { r['bid_final_cost_nds'] if r['rebid'] },
          width: 20
        },
        c21: {
          type: :string, style: :td, no_merge: true, value: ->(r) { r['bid_winner_name'] }, width: 60, part2: true
        },
        c22: {
          type: :float, style: :td_money, no_merge: true, value: ->(r) { r['winner_cost_nds'] }, sum: true, width: 20
        },
        c23: { type: :date, style: :td_date, value: ->(r) { r['wp_confirm_date'].try(:to_date) }, width: 15 },
        c24: { type: :float, style: :td_money, value: ->(r) { (c8(r) || 0) - (c22(r) || 0) }, sum: true, width: 20 },
        c25: {
          type: :float, style: :td_percent, value: ->(r) { c8(r).to_f == 0 ? nil : c24(r) / c8(r).to_f }, width: 15,
          sum: true, sum_value: ->(g) { g["c8_total"] == 0 ? nil : g["c24_total"] / g["c8_total"].to_f },
          sum_style: :sum_percent, persent_formula: { numerator: 26, denomenator: 7 } },
        c26: { type: :float, style: :td_money, value: ->(r) { c9(r) - (c22(r) || 0) }, sum: true, width: 20 },
        c27: {
          type: :float, style: :td_percent, value: ->(r) { c9(r) == 0 ? nil : c26(r) / c9(r).to_f }, width: 15,
          sum: true, sum_value: ->(g) { g["c9_total"] == 0 ? nil : g["c26_total"] / g["c9_total"].to_f },
          sum_style: :sum_percent, persent_formula: { numerator: 28, denomenator: 9 }
        },
        c28: { type: :float, style: :td_money, value: ->(r) { c20(r) - (c22(r) || 0) }, sum: true, width: 20 },
        c29: {
          type: :float, style: :td_percent, value: ->(r) { (c20(r) == 0 ? nil : c28(r) / c20(r).to_f) }, width: 15,
          sum: true, sum_value: ->(g) { g["c20_total"] == 0 ? nil : g["c28_total"] / g["c20_total"].to_f },
          sum_style: :sum_percent, persent_formula: { numerator: 30, denomenator: 20 }
        },
        c30: { type: :string, style: :td, value: ->(r) { r['contract_status'] }, width: 30, part2: true, part3: true },
        c31: { type: :date, style: :td_date, value: ->(r) { r['plan_contract_date'].try(:to_date) }, width: 15 },
        c32: { type: :date, style: :td_date, value: ->(r) { r['contract_confirm_date'].try(:to_date) }, width: 15 },
        c33: { type: :float, style: :td_money, value: ->(r) { r['contract_spec_cost_nds'] }, sum: true, width: 20 },
        # c33: { type: :string, style: :td, value: ->(r) { r['is_sme'] }, width: 30 },
        # c34: { type: :float, style: :td_money, value: ->(r) { c33(r) ? c32(r) : nil }, sum: true, width: 30 },
        # c35: {
        #   type: :float, style: :td_percent, value: ->(r) { c33(r) ? 1.0 : nil }, width: 30,
        #   sum: true, sum_value: ->(g) { g["c32_total"] == 0 ? nil : g["c34_total"] / g["c32_total"].to_f },
        #   sum_style: :sum_percent
        # },
        # c36: { type: :string, style: :td, value: ->(r) { c37(r) > 0 ? 'МСП' : nil }, width: 30 },
        # c37: { type: :integer, style: :td, value: ->(r) { r['sub_cnt'] }, width: 30 },
        # c38: { type: :float, style: :td_money, value: ->(r) { r['sub_cost_nds'] || 0 }, sum: true, width: 30 },
        # c39: {
        #   type: :float, style: :td_percent, value: ->(r) { c32(r) && c32(r) != 0 ? c38(r) / c32(r).to_f : nil },
        #   width: 30,
        #   sum: true, sum_value: ->(g) { g["c32_total"] == 0 ? nil : g["c38_total"] / g["c32_total"].to_f },
        #   sum_style: :sum_percent
        # },
        # c40: {
        #   type: :float, style: :td_money,
        #   value: (lambda do |r|
        #     return c34(r) if c33(r) == 'МСП'
        #     return c38(r) if c36(r) == 'МСП'
        #     0
        #   end), sum: true, width: 30
        # },
        # c41: {
        #   type: :float, style: :td_percent, value: ->(r) { c32(r) && c32(r) != 0 ? c40(r) / c32(r).to_f : nil },
        #   width: 30,
        #   sum: true, sum_value: ->(g) { g["c32_total"] == 0 ? nil : g["c40_total"] / g["c32_total"].to_f },
        #   sum_style: :sum_percent
        # }
        c34: { type: :string, style: :td, value: ->(r) { }, width: 30 },
        c35: { type: :float, style: :td_money, value: ->(r) { }, sum: true, width: 30 },
        c36: {
          type: :float, style: :td_percent, value: ->(r) { }, width: 30,
          sum: true, sum_value: ->(g) { },
          sum_style: :sum_percent
        },
        c37: { type: :string, style: :td, value: ->(r) { }, width: 30 },
        c38: { type: :integer, style: :td, value: ->(r) { }, width: 30 },
        c39: { type: :float, style: :td_money, value: ->(r) { }, sum: true, width: 30 },
        c40: {
          type: :float, style: :td_percent, value: ->(r) { },
          width: 30,
          sum: true, sum_value: ->(g) { },
          sum_style: :sum_percent
        },
        c41: {
          type: :float, style: :td_money,
          value: ->(r) { }, sum: true, width: 30
        },
        c42: {
          type: :float, style: :td_percent, value: ->(r) { },
          width: 30,
          sum: true, sum_value: ->(g) { },
          sum_style: :sum_percent
        }
      }

      COLUMNS.each_pair do |ckey, cval|
        define_singleton_method(ckey) { |r| cval[:value].call(r) }
      end
    end
  end
end

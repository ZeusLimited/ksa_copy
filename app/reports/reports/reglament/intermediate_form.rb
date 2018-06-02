module Reports
  module Reglament
    class IntermediateForm < Reports::Base
      attr_accessor :vz

      def groups
        @groups ||= YAML.load(ERB.new(File.read("#{structures}/high_tech_result.yml")).result(binding))
      end

      def another_groups
        @another_groups ||= YAML.load(ERB.new(File.read("#{dir_structures}/another_groups.yml")).result)
      end

      def default_params
        @default_params ||= {
          begin_date: date_begin.to_date,
          end_date: date_end.to_date,
          subj_type: -1,
          vz: vz.to_i
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

      def self.row_title(suffix)
        I18n.t("#{to_s.underscore}.row_titles.#{suffix}")
      end

      TOTAL_COLUMNS = {
        c1: { type: :integer, style: :td, value: ->(r) { r['cnt'] }, width: 15 },
        c2: { type: :float, style: :td_money, value: ->(r) { r['plan_cost'] }, width: 20 },
        c3: { type: :float, style: :td_money, value: ->(r) { r['plan_cost_nds'] }, width: 20 },
        c4: { type: :float, style: :td_money, value: ->(r) { r['public_cost'] }, width: 20 },
        c5: { type: :float, style: :td_money, value: ->(r) { r['public_cost_nds'] }, width: 20 },
        c6: { type: :float, style: :td_money, value: ->(r) { r['winner_cost'] }, width: 20 },
        c7: { type: :float, style: :td_money, value: ->(r) { r['winner_cost_nds'] }, width: 20 }
      }

      COLUMNS = {
        c1: { type: :integer, style: :td, width: 05, part2: true, part3: true },
        c2: {
          type: :string, style: :td, value: ->(r) { r['root_customer_name'] }, width: 25, part2: true, part3: true
        },
        c7: { type: :string, style: :td, value: ->(r) { r['lot_name'].strip }, width: 60, part2: true, part3: true },
        c8: { type: :string, style: :td_right, value: ->(r) { r['lot_num'] }, width: 15, part2: true, part3: true },
        c10: { type: :string, style: :td, value: ->(r) { r['org_name'] }, width: 40, part2: true, part3: true },
        c12: { type: :string, style: :td, value: ->(r) { r['gkpz_ttype_name'] }, width: 15, part2: true, part3: true },
        c13: { type: :string, style: :td, value: ->(r) { r['fact_ttype_name'] }, width: 15, part2: true },
        c14: { type: :string, style: :td, value: ->(r) { r['fact_ei'] }, width: 15 },
        c17: { type: :float, style: :td_money, value: ->(r) { r['s_cost_nds'] }, sum: true, width: 20, part2: true },
        c19: {
          type: :date, style: :td_date, value: ->(r) { r['gkpz_announce_date'].try(:to_date) },
          width: 15, part2: true, part3: true
        },
        c20: {
          type: :date, style: :td_date, value: ->(r) { r['fact_announce_date'].try(:to_date) }, width: 15, part2: true
        },
        c21: {
          type: :date, style: :td_date, value: ->(r) { r['gkpz_open_date'].try(:getlocal, Time.zone.utc_offset).try(:to_date) }, width: 15,
          part2: true
        },
        c22: {
          type: :date, style: :td_date, value: ->(r) { r['op_open_date'].try(:getlocal, Time.zone.utc_offset).try(:to_date) }, width: 15,
          part2: true
        },
        c24: {
          type: :date, style: :td_date, value: ->(r) { r['protocol_date_plan'].try(:getlocal, Time.zone.utc_offset).try(:to_date) },
          part2: true, width: 15
        },
        c25: { type: :date, style: :td_date, value: ->(r) { r['wp_confirm_date'].try(:to_date) }, part2: true, width: 15 },
        c27: { type: :integer, style: :td, value: ->(r) { r['cnt_offers'] }, part2: true, width: 15 },
        c28: { type: :string, style: :td, no_merge: true, value: ->(r) { r['contr_name'] }, part2: true, width: 60 },
        c29: {
          type: :float, style: :td_money, no_merge: true, value: ->(r) { r['bid_cost_nds'] }, part2: true, width: 20
        },
        c30: { type: :float, style: :td_money, value: ->(r) { r['average_cost'] }, part2: true, sum: true, width: 20 },
        c31: { type: :string, style: :td, no_merge: true, value: ->(r) { r['bid_reject_name'] }, part2: true, width: 60 },
        c32: { type: :string, style: :td_center, value: ->(r) { r['rebid'] ? '+' : '-' }, part2: true, width: 15 },
        c33: {
          type: :float, style: :td_money, no_merge: true, value: ->(r) { r['bid_final_cost_nds'] if r['rebid'] }, part2: true, width: 20
        },
        c35: {
          type: :float, style: :td_money, no_merge: true, value: ->(r) { r['winner_cost_nds'] }, part2: true, sum: true, width: 20
        },
        c36: {
          type: :float, style: :td_money, no_merge: true, value: ->(r) { r['winner_final_cost_nds'] }, part2: true, sum: true,
          width: 20
        },
        c37: {
          type: :string, style: :td, no_merge: true, value: ->(r) { r['bid_winner_name'] }, width: 60, part2: true
        },
        c40: { type: :float, style: :td_money, value: ->(r) { c17(r) - (c36(r) || 0) }, part2: true, sum: true, width: 20 },
        c41: {
          type: :float, style: :td_percent, value: ->(r) { c17(r) == 0 ? nil : c40(r) / c17(r).to_f }, part2: true, width: 15,
          sum: true, sum_value: ->(g) { g["c17_total"] == 0 ? nil : g["c40_total"] / g["c17_total"].to_f },
          sum_style: :sum_percent
        },
        c46: { type: :date, style: :td_date, value: ->(r) { r['plan_contract_date'].try(:to_date) }, part2: true, width: 15 },
        c47: { type: :date, style: :td_date, value: ->(r) { r['contract_confirm_date'].try(:to_date) }, part2: true, width: 15 },
        c48: {
          type: :string, style: :td, value: ->(r) { r['non_contract_reason'] }, width: 30, part2: true, part3: true
        },
        c49: { type: :float, style: :td_money, value: ->(r) { r['contract_spec_cost_nds'] }, part2: true, sum: true, width: 20 }
      }

      COLUMNS.each_pair do |ckey, cval|
        define_singleton_method(ckey) { |r| cval[:value].call(r) }
      end

      TOTAL_COLUMNS.each_pair do |ckey, cval|
        define_singleton_method(ckey) { |r| cval[:value].call(r) }
      end
    end
  end
end

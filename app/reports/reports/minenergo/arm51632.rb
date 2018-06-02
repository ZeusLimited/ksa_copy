module Reports
  module Minenergo
    class Arm51632 < Reports::Base
      include ArmMinenergo

      attr_accessor :par22222, :par22222_ps, :par33333, :par33333_ps, :par44444, :par44444_ps, :par55555, :par77777
      attr_accessor :par55555_name, :par77777_name
      attr_accessor :winners, :consumers

      def default_params
        @default_params ||= {
          begin_date: date_begin.to_date,
          end_date: date_end.to_date,
          customer: customer.to_i
        }.with_indifferent_access
      end

      def generate_special_file(arm_dept, quarter)
        mas = ["((//51632:#{quarter}:#{arm_dept}:++"]
        add_general_content(mas)
        mas << add_line(22_222, get_additional_info(par22222, par22222_ps))
        mas << add_line(33_333, get_additional_info(par33333, par33333_ps))
        mas << add_line(44_444, get_additional_info(par44444, par44444_ps))
        mas << add_line(55_555, get_user_info(par55555))
        mas << add_line(77_777, get_user_info(par77777))
        mas << "==))"
        mas.join("\r\n")
      end

      COLUMNS = {
        c1: { type: :string, style: :td, value: ->(r) { r['root_name'] }, width: 25 },
        c2: { type: :string, style: :td, value: ->(r) { r['root_customer_name'] }, width: 25 },
        c3: { type: :string, style: :td, value: ->(r) { r['direction_name'].strip }, width: 15 },
        c4: { type: :string, style: :td, value: ->(r) { r['invest_project_name'] }, width: 25 },
        c5: { type: :string, style: :td, value: ->(r) { r['invest_object_name'] }, width: 25 },
        c6: { type: :date, style: :td_date, value: ->(r) { r['date_install'].try(:to_date) }, width: 15 },
        c7: { type: :float, style: :td_money, value: ->(r) { r['invest_power_mvt'] }, width: 15 },
        c8: { type: :float, style: :td_money, value: ->(r) { r['invest_power_mva'] }, width: 15 },
        c9: { type: :float, style: :td_money, value: ->(r) { r['invest_power_km'] }, width: 15 },
        c10: { type: :string, style: :td, value: ->(r) { r['product_type_name'] }, width: 15 },
        c10_1: { type: :string, style: :td_right, value: ->(r) { r['lot_num'] }, width: 15 },
        c11: { type: :string, style: :td, value: ->(r) { r['lot_name'].strip }, width: 60 },
        c12: { type: :string, style: :td, value: ->(r) { r['financing_name'] }, width: 15 },
        c13: { type: :string, style: :td, value: ->(r) { r['org_name'] }, width: 40 },
        c14: {
          type: :float, style: :td_money, value: ->(r) { to_arm_thousand(r['gkpz_cost']) }, sum: true, width: 20
        },
        c15: { type: :string, style: :td, value: ->(r) { r['cost_doc'] }, width: 40 },
        c16: { type: :float, style: :td_money, value: ->(r) { to_arm_thousand(r['s_cost']) }, sum: true, width: 20 },
        c17: { type: :string, style: :td, value: ->(r) { r['gkpz_ttype_name'] }, width: 15 },
        c18: { type: :string, style: :td, value: ->(r) { r['fact_ttype_name'] }, width: 15 },
        c19: { type: :integer, style: :td, value: ->(r) { r['registred_bidders_count'] }, width: 15 },
        c20: { type: :integer, style: :td, value: ->(r) { r['cnt_offers'] }, width: 15 },
        c21: { type: :string, style: :td, no_merge: true, value: ->(r) { r['contr_name'] }, width: 60 },
        c22: {
          type: :float, style: :td_money, no_merge: true, value: ->(r) { to_arm_thousand(r['bid_cost']) },
          width: 20
        },
        c23: { type: :string, style: :td, no_merge: true, value: ->(r) { r['bid_reject_name'] }, width: 60 },
        c24: { type: :integer, style: :td_center, value: ->(r) { r['rebid_count'] }, width: 15 },
        c25: {
          type: :float, style: :td_money, no_merge: true,
          value: ->(r) { c24(r) != 0 ? to_arm_thousand(r['bid_final_cost']) : 0 }, width: 20
        },
        c26: {
          type: :float, style: :td_money, value: ->(r) { to_arm_thousand(r['winner_final_cost']) }, sum: true,
          width: 20
        },
        c27: {
          type: :string, style: :td, value: ->(r) { r['bid_winner_name'] }, width: 60, part2: true
        },
        c28_1: {
          type: :float, style: :td_money, value: ->(r) { to_arm_thousand(r['contract_spec_cost_nds']) }, sum: true,
          width: 20
        },
        c28_2: {
          type: :float, style: :td_money, value: ->(r) { to_arm_thousand(r['contract_spec_cost']) }, sum: true,
          width: 20
        },
        c29: {
          type: :float, style: :td_money, value: ->(r) { to_arm_thousand(r['amount_finance_nds']) }, sum: true,
          width: 20
        },
        c30: { type: :integer, style: :td_right, value: ->(r) { r['etp_num'] }, width: 15 },
        c31: { type: :string, style: :td_right, value: ->(r) { c30(r) ? 'b2b-center.ru' : nil }, width: 15 },
        c32: {
          type: :date, style: :td_date, value: ->(r) { r['gkpz_announce_date'].try(:to_date) }, width: 15
        },
        c33: {
          type: :date, style: :td_date, value: ->(r) { r['fact_announce_date'].try(:to_date) }, width: 15, part2: true
        },
        c34: {
          type: :date, style: :td_date, value: ->(r) { r['op_open_date'].try(:getlocal, Time.zone.utc_offset).try(:to_date) }, width: 15,
          part2: true
        },
        c35: { type: :date, style: :td_date, value: ->(r) { r['wp_confirm_date'].try(:to_date) }, width: 15 },

        c36: { type: :string, style: :td_right, value: ->(r) { r['regulation_item_num'] }, width: 20 },
        c37: { type: :string, style: :td_right, value: ->(r) { r['responcible_dept'] }, width: 20 },
        c38: { type: :string, style: :td_right, value: ->(r) { r['order_date'].try(:to_date) }, width: 15 },
        c39: { type: :string, style: :td_right, value: ->(r) { r['order_num'] }, width: 15 },
        c40: { type: :date, style: :td_date, value: ->(r) { r['plan_contract_date'].try(:to_date) }, width: 15 },
        c41: { type: :date, style: :td_date, value: ->(r) { r['contract_confirm_date'].try(:to_date) }, width: 15 },
        c42: {
          type: :string, style: :td_right, value: ->(r) { r['gkpz_delivery_date_begin'].try(:to_date) }, width: 15
        },
        c43: {
          type: :string, style: :td_right, value: ->(r) { r['contract_delivery_date_begin'].try(:to_date) }, width: 15
        },
        c44: {
          type: :string, style: :td_right, value: ->(r) { r['contract_delivery_date_end'].try(:to_date) }, width: 15
        },
        c45: {
          type: :string, style: :td,
          value: ->(r) { [r['non_public_reason'], r['non_contract_reason'], r['non_delivery_reason']].compact.join('; ') },
          width: 30
        },
        c46: { type: :string, style: :td, value: ->(r) { r['note'] }, width: 30 }
      }

      COLUMNS.each_pair do |ckey, cval|
        define_singleton_method(ckey) { |r| cval[:value].call(r) }
      end

      private

      def add_general_content(results)
        displayed_rows = 0
        part1_sql_rows.each_with_index do |row, index|
          displayed_rows = row['cnt_offers'] if displayed_rows == 0
          is_first_row = displayed_rows == row['cnt_offers']
          values = COLUMNS.reject { |key| [:c10_1, :c28_2].include?(key) }.map do |key, properties|
            p = properties[:value].call(row) if is_first_row || [:c1, :c2].include?(key) || properties[:no_merge]
            reject_special_symbols(p) || default_value(properties[:type])
          end
          displayed_rows -= 1
          results << add_line(1_000 + index, values.join(':'))
        end
      end
    end
  end
end

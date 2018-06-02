module Reports
  module Minenergo
    class Arm51633 < Reports::Base
      include ArmMinenergo

      attr_accessor :par55555, :par77777, :par55555_name, :par77777_name

      def default_params
        @default_params ||= {
          begin_date: date_begin.to_date,
          end_date: date_end.to_date,
          gkpz_year: gkpz_year.to_i,
          customer: customer.to_i
        }.with_indifferent_access
      end

      def generate_special_file(arm_dept, quarter)
        mas = ["((//51633:#{quarter}:#{arm_dept}:++"]
        add_general_content(part1_sql_rows, 1_000, mas)
        add_general_content(part3_sql_rows, 9_000, mas)
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
        c21: {
          type: :string, style: :td, part1_no_merge: true, part3_no_merge: true, value: ->(r) { r['contr_name'] },
          width: 60
        },
        c22: {
          type: :float, style: :td_money, part1_no_merge: true, part3_no_merge: true,
          value: ->(r) { to_arm_thousand(r['bid_cost']) }, width: 20
        },
        c23: {
          type: :string, style: :td, part1_no_merge: true, part3_no_merge: true, value: ->(r) { r['bid_reject_name'] },
          width: 60
        },
        c24: { type: :integer, style: :td_center, value: ->(r) { r['rebid_count'] }, width: 15 },
        c25: {
          type: :float, style: :td_money, part1_no_merge: true, part3_no_merge: true,
          value: ->(r) { c24(r) != 0 ? to_arm_thousand(r['bid_final_cost']) : 0 }, width: 20
        },
        c26: {
          type: :float, style: :td_money, part1_no_merge: true,
          value: ->(r) { to_arm_thousand(r['winner_final_cost']) }, sum: true, width: 20
        },
        c27: {
          type: :string, style: :td, part1_no_merge: true, value: ->(r) { r['bid_winner_name'] }, width: 60
        },
        c28: { type: :integer, style: :td_right, value: ->(r) { r['etp_num'] }, width: 15 },
        c29: { type: :string, style: :td_right, value: ->(r) { c28(r) ? 'b2b-center.ru' : nil }, width: 15 },
        c30: {
          type: :date, style: :td_date, value: ->(r) { r['gkpz_announce_date'].try(:to_date) }, width: 15
        },
        c31: {
          type: :date, style: :td_date, value: ->(r) { r['fact_announce_date'].try(:to_date) }, width: 15, part2: true
        },
        c32: {
          type: :date, style: :td_date, value: ->(r) { r['op_open_date'].try(:to_date) }, width: 15, part2: true
        },
        c33: { type: :date, style: :td_date, value: ->(r) { r['wp_confirm_date'].try(:to_date) }, width: 15 },
        c34: { type: :date, style: :td_date, value: ->(r) { r['contract_confirm_date'].try(:to_date) }, width: 15 },
        c35: {
          type: :string, style: :td_right, value: ->(r) { r['gkpz_delivery_date_begin'].try(:to_date) }, width: 15
        },
        c36: {
          type: :string, style: :td,
          value: ->(r) { [r['non_public_reason'], r['non_contract_reason'], r['non_delivery_reason']].compact.join('; ') },
          width: 30
        },
        c37: { type: :string, style: :td, value: ->(r) { r['future_plan_name'] }, width: 30 },
        c38: { type: :string, style: :td, value: ->(r) { r['note'] }, width: 30 }
      }

      COLUMNS.each_pair do |ckey, cval|
        define_singleton_method(ckey) { |r| cval[:value].call(r) }
      end

      private

      def add_general_content(rows, start_index, results)
        displayed_rows = 0
        rows.each_with_index do |row, index|
          displayed_rows = row['cnt_offers'] if displayed_rows == 0
          is_first_row = displayed_rows == row['cnt_offers']
          values = COLUMNS.reject { |key| key == :c10_1 }.map do |key, properties|
            p = properties[:value].call(row) if is_first_row || [:c1, :c2].include?(key) || properties[:part1_no_merge]
            reject_special_symbols(p) || default_value(properties[:type])
          end
          displayed_rows -= 1
          results << add_line(start_index + index, values.join(':'))
        end
      end
    end
  end
end

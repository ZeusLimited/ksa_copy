module Reports
  module Minenergo
    class Arm51635 < Reports::Base
      include ArmMinenergo

      attr_accessor :par22222, :par55555, :par77777, :par55555_name, :par77777_name, :consumers

      def default_params
        @default_params ||= {
          begin_date: date_begin.to_date,
          end_date: date_end.to_date,
          date_gkpz_on_state: date_gkpz_on_state.to_date,
          gkpz_year: gkpz_year,
          customer: customer.to_i
        }.with_indifferent_access
      end

      def generate_special_file(arm_dept, quarter)
        mas = ["((//51635:#{quarter}:#{arm_dept}:++"]
        add_general_content(mas)
        mas << add_line(22_222, get_additional_info(par22222))
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
        c13: { type: :string, style: :td, value: ->(r) { r['organizer_name'] }, width: 40 },
        c14: {
          type: :float, style: :td_money, value: ->(r) { to_arm_thousand(r['gkpz_cost']) }, sum: true, width: 20
        },
        c15: { type: :string, style: :td, value: ->(r) { r['cost_doc'] }, width: 40 },
        c16: { type: :string, style: :td, value: ->(r) { r['gkpz_ttype_name'] }, width: 15 },
        c17: {
          type: :date, style: :td_date, value: ->(r) { r['gkpz_announce_date'].try(:to_date) }, width: 15
        },
        c18: { type: :date, style: :td_date, value: ->(r) { r['plan_contract_date'].try(:to_date) }, width: 15 },
        c19: {
          type: :string, style: :td_right, value: ->(r) { r['gkpz_delivery_date_begin'].try(:to_date) }, width: 15
        },
        c20: { type: :string, style: :td, value: ->(r) { r['note'] }, width: 30 }
      }

      COLUMNS.each_pair do |ckey, cval|
        define_singleton_method(ckey) { |r| cval[:value].call(r) }
      end

      def self.to_arm_thousand(val)
        return 0 if val.nil?
        (val / 1000.0).round(3)
      end

      private

      def add_general_content(results)
        gkpz_sql_rows.each_with_index do |row, index|
          values = COLUMNS.reject { |key| key == :c10_1 }.values.map do |properties|
            reject_special_symbols(properties[:value].call(row)) || default_value(properties[:type])
          end
          results << add_line(1_000 + index, values.join(':'))
        end
      end

      def get_additional_info(param)
        "#{param}::"
      end
    end
  end
end

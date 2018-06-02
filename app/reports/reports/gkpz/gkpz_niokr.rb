module Reports
  module Gkpz
    class GkpzNiokr < Reports::Base
      attr_accessor :show_status, :gkpz_state

      def groups
        @groups ||= YAML.load(ERB.new(File.read("#{structures}/gkpz_niokr.yml")).result(binding))
      end

      def default_params
        @default_params ||= {
          begin_date: date_begin.to_date,
          end_date: date_end.to_date,
          date_gkpz_on_state: date_gkpz_on_state.to_date,
          gkpz_year: gkpz_year.to_i
        }.with_indifferent_access
      end

      def result_rows(filter)
        gkpz_sql_rows.select do |r|
          filter.all? { |k, v| Array(v).include?(r[k]) }
        end.sort_by { |r| r['sort_order'] }
      end

      COLUMNS = {
        c1: { type: :string, style: :td, value: ->(r) { r['specifiaction_name'] }, width: 60 },
        c2: { type: :string, style: :td, value: ->(r) { r['requirements'] }, width: 30 },
        c3: { type: :integer, style: :td, value: ->(r) { r['qty'] }, width: 11 },
        c4: { type: :string, style: :td, value: ->(r) { r['unit_code'] }, width: 20 },
        c5: { type: :string, style: :td, value: ->(r) { r['unit_name'] }, width: 20 },
        c6: { type: :string, style: :td, value: ->(r) { r['fias_okato'] }, width: 20 },
        c7: { type: :string, style: :td, value: ->(r) { r['fias_name'] }, width: 20 },
        c8: { type: :string, style: :td, value: ->(r) { r['lot_num'] }, width: 20 },
        c9: { type: :string, style: :td, value: ->(r) { r['financing_name'] }, width: 20 },
        c10: { type: :float, style: :td_money, value: ->(r) { r['cost'] }, sum: true, width: 15 },
        c11: { type: :float, style: :td_money, value: ->(r) { r['cost_nds'] }, sum: true, width: 15 },
        c12: { type: :date, style: :td_date, value: ->(r) { r['announce_date'].try(:to_date) }, width: 20 },
        c13: { type: :string, style: :td, value: ->(r) { r['tender_type_name'] }, width: 15 },
        c13_1: { type: :string, style: :td, value: ->(r) { r['sme_type_name'] }, width: 25 },
        c14: { type: :string, style: :td, value: ->(r) { r['is_elform'] }, width: 15 },
        c15: { type: :string, style: :td, value: ->(r) { r['org_name'] }, width: 30 },
        c16: { type: :string, style: :td, value: ->(r) { r['okdp_code'] }, width: 10 },
        c17: { type: :string, style: :td, value: ->(r) { r['okved_code'] }, width: 10 },
        c18: { type: :string, style: :td, value: ->(r) { r['commission_type_name'] }, width: 15 },
        c19: { type: :string, style: :td, value: ->(r) { r['mon_dept'] }, width: 40 },
        c20: { type: :date, style: :td_date, value: ->(r) { r['delivery_date_begin'].try(:to_date) }, width: 15 },
        c20_1: { type: :integer, style: :td, value: ->(r) { c20(r).year }, width: 10 },
        c21: { type: :date, style: :td_date, value: ->(r) { r['delivery_date_end'].try(:to_date) }, width: 15 },
        c21_1: { type: :integer, style: :td, value: ->(r) { c21(r).year }, width: 10 },
        c22: { type: :string, style: :td, value: ->(r) { r['contractor_names'] }, width: 50 },
        c23: { type: :string, style: :td, value: ->(r) { r['bp_item'] }, width: 20 },
        c24: { type: :float, style: :td_money, value: ->(r) { r['amount_mastery1'] }, sum: true, width: 15 },
        c25: { type: :float, style: :td_money, value: ->(r) { r['amount_mastery_nds1'] }, sum: true, width: 15 },
        c26: { type: :float, style: :td_money, value: ->(r) { r['amount_mastery2'] }, sum: true, width: 15 },
        c27: { type: :float, style: :td_money, value: ->(r) { r['amount_mastery_nds2'] }, sum: true, width: 15 },
        c28: { type: :float, style: :td_money, value: ->(r) { r['amount_mastery3'] }, sum: true, width: 15 },
        c29: { type: :float, style: :td_money, value: ->(r) { r['amount_mastery_nds3'] }, sum: true, width: 15 },
        c30: { type: :float, style: :td_money, value: ->(r) { r['amount_mastery4'] }, sum: true, width: 15 },
        c31: { type: :float, style: :td_money, value: ->(r) { r['amount_mastery_nds4'] }, sum: true, width: 15 },
        c32: { type: :float, style: :td_money, value: ->(r) { r['amount_mastery5'] }, sum: true, width: 15 },
        c33: { type: :float, style: :td_money, value: ->(r) { r['amount_mastery_nds5'] }, sum: true, width: 15 },
        c34: { type: :float, style: :td_money, value: ->(r) { r['amount_finance1'] }, sum: true, width: 15 },
        c35: { type: :float, style: :td_money, value: ->(r) { r['amount_finance_nds1'] }, sum: true, width: 15 },
        c36: { type: :float, style: :td_money, value: ->(r) { r['amount_finance2'] }, sum: true, width: 15 },
        c37: { type: :float, style: :td_money, value: ->(r) { r['amount_finance_nds2'] }, sum: true, width: 15 },
        c38: { type: :float, style: :td_money, value: ->(r) { r['amount_finance3'] }, sum: true, width: 15 },
        c39: { type: :float, style: :td_money, value: ->(r) { r['amount_finance_nds3'] }, sum: true, width: 15 },
        c40: { type: :float, style: :td_money, value: ->(r) { r['amount_finance4'] }, sum: true, width: 15 },
        c41: { type: :float, style: :td_money, value: ->(r) { r['amount_finance_nds4'] }, sum: true, width: 15 },
        c42: { type: :float, style: :td_money, value: ->(r) { r['amount_finance5'] }, sum: true, width: 15 },
        c43: { type: :float, style: :td_money, value: ->(r) { r['amount_finance_nds5'] }, sum: true, width: 15 },
        c44: { type: :string, style: :td, value: ->(r) { [r['regulation_item_num'], r['tender_type_explanations'], r['note']].compact.join('; ') }, width: 80 },
        c45: { type: :string, style: :td, value: ->(r) { r['curator'] }, width: 20 },
        c46: { type: :string, style: :td, value: ->(r) { r['tech_curator'] }, width: 20 }
      }

      COLUMNS.each_pair do |ckey, cval|
        define_singleton_method(ckey) { |r| cval[:value].call(r) }
      end
    end
  end
end

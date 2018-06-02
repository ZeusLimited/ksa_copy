module Reports
  module Gkpz
    class Gkpz < Reports::Base
      attr_accessor :show_status, :show_root, :show_cust, :status_tender, :show_color, :gkpz_state, :divide_by_customers

      def groups
        @groups ||= YAML.load(ERB.new(File.read("#{structures}/gkpz.yml")).result(binding))
      end

      def sme_groups
        @sme_groups ||= YAML.load(ERB.new(File.read("#{structures}/gkpz_sme.yml")).result)
      end

      def default_params
        @default_params ||= {
          begin_date: date_begin.to_date,
          end_date: date_end.to_date,
          date_gkpz_on_state: date_gkpz_on_state.to_date
        }.with_indifferent_access
      end

      def result_rows(filter)
        filter_rows(rows_with_indifferent_access, filter).sort_by { |r| r['sort_order'] }
      end

      def result_rows_by_customers
        rows_with_indifferent_access.group_by { |r| r['root_customer_name'] }
      end

      def filter_rows(rows, filter)
        rows.select do |r|
          filter.all? { |k, v| Array(v).include?(r[k]) }
        end
      end

      def total_rows(filter)
        result_rows(filter).group_by { |r| r["tender_type_id"] }.map do |k, v|
          {
            ref_id: k,
            cnt: v.sum { |r| r['cnt'] },
            cost: to_thousand(v.sum { |r| r['rn'] == 1 ? r['cost'] : 0.0 }),
            cost_nds: to_thousand(v.sum { |r| r['rn'] == 1 ? r['cost_nds'] : 0.0 })
          }.with_indifferent_access
        end
      end

      def rows_with_indifferent_access
        @rows_with_indifferent_access ||= gkpz_sql_rows.map(&:with_indifferent_access)
      end

      def ref_tender_types
        @ref_tender_types ||= Dictionary.tender_types
      end

      COLUMNS = {
        consumer_name: { type: :string, style: :td, value: ->(r) { [r['root_customer_name'], r['consumer_name']].compact.uniq.join(' --> ') }, width: 30 },
        specifiaction_name: { type: :string, style: :td, value: ->(r) { r['specifiaction_name'] }, width: 60 },
        requirements: { type: :string, style: :td, value: ->(r) { r['requirements'] }, width: 30 },
        qty: { type: :integer, style: :td, value: ->(r) { r['qty'] }, width: 11 },
        unit_code: { type: :string, style: :td, value: ->(r) { r['unit_code'] }, width: 20 },
        unit_name: { type: :string, style: :td, value: ->(r) { r['unit_name'] }, width: 20 },
        fias_okato: { type: :string, style: :td, no_title: true, no_merge: true, value: ->(r) { r['fias_okato'] }, width: 20 },
        fias_name: {
          type: :string, style: :td, no_title: true, no_merge: true,
          value: ->(r) { r['fias_name'] }, width: 20
        },
        lot_num: { type: :string, style: :td, value: ->(r) { r['lot_num'] }, width: 20 },
        financing_name: { type: :string, style: :td, no_title: true, value: ->(r) { r['financing_name'] }, width: 20 },
        cost: { type: :float, style: :td_money, value: ->(r) { r['cost'] }, sum: true, width: 15 },
        cost_nds: { type: :float, style: :td_money, value: ->(r) { r['cost_nds'] }, sum: true, width: 15 },
        announce_date: { type: :date, style: :td_date, value: ->(r) { r['announce_date'].try(:to_date) }, width: 20 },
        tender_type_name: {
          type: :string, style: :td, value: ->(r) { [r['tender_type_name'], r['pre_tender_type_name']].compact.join(' ') }, width: 15 },
        sme_type_name: { type: :string, style: :td, value: ->(r) { r['sme_type_name'] }, width: 25 },
        order1352_name: { type: :string, style: :td, value: ->(r) { r['order1352_name'] }, width: 25 },
        c_null1: { type: :string, style: :td, value: ->(r) { }, width: 25 },
        is_elform: { type: :string, style: :td, value: ->(r) { r['is_elform'] }, width: 15 },
        org_name: { type: :string, style: :td, value: ->(r) { r['org_name'] }, width: 30 },
        okved_code: { type: :string, style: :td, value: ->(r) { r['okved_code'] }, width: 10 },
        okdp_code: { type: :string, style: :td, value: ->(r) { r['okdp_code'] }, width: 10 },
        commission_type_name: { type: :string, style: :td, value: ->(r) { r['commission_type_name'] }, width: 15 },
        mon_dept: { type: :string, style: :td, no_title: true, value: ->(r) { r['mon_dept'] }, width: 40 },
        delivery_date_begin: { type: :date, style: :td_date, value: ->(r) { r['delivery_date_begin'].try(:to_date) }, width: 15 },
        delivery_date_begin_year: { type: :integer, style: :td, value: ->(r) { delivery_date_begin(r).year }, width: 10 },
        delivery_date_end: { type: :date, style: :td_date, value: ->(r) { r['delivery_date_end'].try(:to_date) }, width: 15 },
        delivery_date_end_year: { type: :integer, style: :td, value: ->(r) { delivery_date_end(r).year }, width: 10 },
        contractor_names: { type: :string, style: :td, value: ->(r) { r['contractor_names'] || r['potential_participants'] }, width: 50 },
        bp_item: { type: :string, style: :td, no_title: true, value: ->(r) { r['bp_item'] }, width: 20 },
        amount_mastery1: { type: :float, style: :td_money, value: ->(r) { r['amount_mastery1'] }, sum: true, width: 15 },
        amount_mastery_nds1: { type: :float, style: :td_money, value: ->(r) { r['amount_mastery_nds1'] }, sum: true, width: 15 },
        amount_mastery2: { type: :float, style: :td_money, value: ->(r) { r['amount_mastery2'] }, sum: true, width: 15 },
        amount_mastery_nds2: { type: :float, style: :td_money, value: ->(r) { r['amount_mastery_nds2'] }, sum: true, width: 15 },
        amount_mastery3: { type: :float, style: :td_money, value: ->(r) { r['amount_mastery3'] }, sum: true, width: 15 },
        amount_mastery_nds3: { type: :float, style: :td_money, value: ->(r) { r['amount_mastery_nds3'] }, sum: true, width: 15 },
        amount_mastery4: { type: :float, style: :td_money, value: ->(r) { r['amount_mastery4'] }, sum: true, width: 15 },
        amount_mastery_nds4: { type: :float, style: :td_money, value: ->(r) { r['amount_mastery_nds4'] }, sum: true, width: 15 },
        amount_mastery5: { type: :float, style: :td_money, value: ->(r) { r['amount_mastery5'] }, sum: true, width: 15 },
        amount_mastery_nds5: { type: :float, style: :td_money, value: ->(r) { r['amount_mastery_nds5'] }, sum: true, width: 15 },
        amount_finance1: { type: :float, style: :td_money, value: ->(r) { r['amount_finance1'] }, sum: true, width: 15 },
        amount_finance_nds1: { type: :float, style: :td_money, value: ->(r) { r['amount_finance_nds1'] }, sum: true, width: 15 },
        amount_finance2: { type: :float, style: :td_money, value: ->(r) { r['amount_finance2'] }, sum: true, width: 15 },
        amount_finance_nds2: { type: :float, style: :td_money, value: ->(r) { r['amount_finance_nds2'] }, sum: true, width: 15 },
        amount_finance3: { type: :float, style: :td_money, value: ->(r) { r['amount_finance3'] }, sum: true, width: 15 },
        amount_finance_nds3: { type: :float, style: :td_money, value: ->(r) { r['amount_finance_nds3'] }, sum: true, width: 15 },
        amount_finance4: { type: :float, style: :td_money, value: ->(r) { r['amount_finance4'] }, sum: true, width: 15 },
        amount_finance_nds4: { type: :float, style: :td_money, value: ->(r) { r['amount_finance_nds4'] }, sum: true, width: 15 },
        amount_finance5: { type: :float, style: :td_money, value: ->(r) { r['amount_finance5'] }, sum: true, width: 15 },
        amount_finance_nds5: { type: :float, style: :td_money, value: ->(r) { r['amount_finance_nds5'] }, sum: true, width: 15 },
        note: { type: :string, style: :td, value: ->(r) { [r['status_name'], r['regulation_item_num'], r['tender_type_explanations'], r['note'], r['state_from_lot']].compact.join('; ') }, width: 80 },
        curator: { type: :string, style: :td, value: ->(r) { r['curator'] }, width: 20 },
        tech_curator: { type: :string, style: :td, value: ->(r) { r['tech_curator'] }, width: 20 }
      }

      LOT_TITLE_COLUMNS = {
        consumer_name: { type: :string, style: :group_row_h2, value: ->(r) { [r['root_customer_name'], r['consumer_name']].compact.uniq.join(' --> ') }, width: 30 },
        specifiaction_name: { type: :string, style: :group_row_h2, value: ->(r) { r['specifiaction_name'] }, width: 60 },
        requirements: { type: :string, style: :group_row_h2, value: ->(r) { r['requirements'] }, width: 30 },
        qty: { type: :integer, style: :group_row_h2, value: ->(r) { r['qty'] }, width: 11 },
        unit_code: { type: :string, style: :group_row_h2, value: ->(r) { r['unit_code'] }, width: 20 },
        unit_name: { type: :string, style: :group_row_h2, value: ->(r) { r['unit_name'] }, width: 20 },
        fias_okato: { type: :string, style: :group_row_h2, no_merge: true, value: ->(r) { nil }, width: 20 },
        fias_name: {
          type: :string, style: :group_row_h2, no_merge: true,
          value: ->(r) { nil }, width: 20
        },
        lot_num: { type: :string, style: :group_row_h2, value: ->(r) { r['lot_num'] }, width: 20 },
        financing_name: { type: :string, style: :group_row_h2, value: ->(r) { nil }, width: 20 },
        cost: { type: :float, style: :group_row_h2_money, value: ->(r) { r['s_cost'] }, sum: true, width: 15 },
        cost_nds: { type: :float, style: :group_row_h2_money, value: ->(r) { r['s_cost_nds'] }, sum: true, width: 15 },
        announce_date: { type: :date, style: :group_row_h2_date, value: ->(r) { r['announce_date'].try(:to_date) }, width: 20 },
        tender_type_name: {
          type: :string, style: :group_row_h2, value: ->(r) { [r['tender_type_name'], r['pre_tender_type_name']].compact.join(' ') }, width: 15 },
        sme_type_name: { type: :string, style: :group_row_h2, value: ->(r) { r['sme_type_name'] }, width: 25 },
        order1352_name: { type: :string, style: :group_row_h2, value: ->(r) { r['order1352_name'] }, width: 25 },
        c_null1: { type: :string, style: :group_row_h2, value: ->(r) { }, width: 25 },
        is_elform: { type: :string, style: :group_row_h2, value: ->(r) { r['is_elform'] }, width: 15 },
        org_name: { type: :string, style: :group_row_h2, value: ->(r) { r['org_name'] }, width: 30 },
        okved_code: { type: :string, style: :group_row_h2, value: ->(r) { r['okved_code'] }, width: 10 },
        okdp_code: { type: :string, style: :group_row_h2, value: ->(r) { r['okdp_code'] }, width: 10 },
        commission_type_name: { type: :string, style: :group_row_h2, value: ->(r) { r['commission_type_name'] }, width: 15 },
        mon_dept: { type: :string, style: :group_row_h2, value: ->(r) { nil }, width: 40 },
        delivery_date_begin: { type: :date, style: :group_row_h2_date, value: ->(r) { r['delivery_date_begin'].try(:to_date) }, width: 15 },
        delivery_date_begin_year: { type: :integer, style: :group_row_h2, value: ->(r) { delivery_date_begin(r).year }, width: 10 },
        delivery_date_end: { type: :date, style: :group_row_h2_date, value: ->(r) { r['delivery_date_end'].try(:to_date) }, width: 15 },
        delivery_date_end_year: { type: :integer, style: :group_row_h2, value: ->(r) { delivery_date_end(r).year }, width: 10 },
        contractor_names: { type: :string, style: :group_row_h2, value: ->(r) { r['contractor_names'] || r['potential_participants'] }, width: 50 },
        bp_item: { type: :string, style: :group_row_h2, value: ->(r) { nil }, width: 20 },
        amount_mastery1: { type: :float, style: :group_row_h2_money, value: ->(r) { r['s_amount_mastery1'] }, sum: true, width: 15 },
        amount_mastery_nds1: { type: :float, style: :group_row_h2_money, value: ->(r) { r['s_amount_mastery_nds1'] }, sum: true, width: 15 },
        amount_mastery2: { type: :float, style: :group_row_h2_money, value: ->(r) { r['s_amount_mastery2'] }, sum: true, width: 15 },
        amount_mastery_nds2: { type: :float, style: :group_row_h2_money, value: ->(r) { r['s_amount_mastery_nds2'] }, sum: true, width: 15 },
        amount_mastery3: { type: :float, style: :group_row_h2_money, value: ->(r) { r['s_amount_mastery3'] }, sum: true, width: 15 },
        amount_mastery_nds3: { type: :float, style: :group_row_h2_money, value: ->(r) { r['s_amount_mastery_nds3'] }, sum: true, width: 15 },
        amount_mastery4: { type: :float, style: :group_row_h2_money, value: ->(r) { r['s_amount_mastery4'] }, sum: true, width: 15 },
        amount_mastery_nds4: { type: :float, style: :group_row_h2_money, value: ->(r) { r['s_amount_mastery_nds4'] }, sum: true, width: 15 },
        amount_mastery5: { type: :float, style: :group_row_h2_money, value: ->(r) { r['s_amount_mastery5'] }, sum: true, width: 15 },
        amount_mastery_nds5: { type: :float, style: :group_row_h2_money, value: ->(r) { r['s_amount_mastery_nds5'] }, sum: true, width: 15 },
        amount_finance1: { type: :float, style: :group_row_h2_money, value: ->(r) { r['s_amount_finance1'] }, sum: true, width: 15 },
        amount_finance_nds1: { type: :float, style: :group_row_h2_money, value: ->(r) { r['s_amount_finance_nds1'] }, sum: true, width: 15 },
        amount_finance2: { type: :float, style: :group_row_h2_money, value: ->(r) { r['s_amount_finance2'] }, sum: true, width: 15 },
        amount_finance_nds2: { type: :float, style: :group_row_h2_money, value: ->(r) { r['s_amount_finance_nds2'] }, sum: true, width: 15 },
        amount_finance3: { type: :float, style: :group_row_h2_money, value: ->(r) { r['s_amount_finance3'] }, sum: true, width: 15 },
        amount_finance_nds3: { type: :float, style: :group_row_h2_money, value: ->(r) { r['s_amount_finance_nds3'] }, sum: true, width: 15 },
        amount_finance4: { type: :float, style: :group_row_h2_money, value: ->(r) { r['s_amount_finance4'] }, sum: true, width: 15 },
        amount_finance_nds4: { type: :float, style: :group_row_h2_money, value: ->(r) { r['s_amount_finance_nds4'] }, sum: true, width: 15 },
        amount_finance5: { type: :float, style: :group_row_h2_money, value: ->(r) { r['s_amount_finance5'] }, sum: true, width: 15 },
        amount_finance_nds5: { type: :float, style: :group_row_h2_money, value: ->(r) { r['s_amount_finance_nds5'] }, sum: true, width: 15 },
        note: { type: :string, style: :group_row_h2, value: ->(r) { [r['status_name'], r['regulation_item_num'], r['tender_type_explanations'], r['note'], r['state_from_lot']].compact.join('; ') }, width: 80 },
        curator: { type: :string, style: :group_row_h2, value: ->(r) { r['curator'] }, width: 20 },
        tech_curator: { type: :string, style: :group_row_h2, value: ->(r) { r['tech_curator'] }, width: 20 }
      }

      COLUMNS.each_pair do |ckey, cval|
        define_singleton_method(ckey) { |r| cval[:value].call(r) }
      end
    end
  end
end

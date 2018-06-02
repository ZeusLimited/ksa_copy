module Reports
  module Reglament
    class InvestResult < Reports::Base
      def groups
        @groups ||= YAML.load(ERB.new(File.read("#{structures}/invest_result.yml")).result(binding))
      end

      def total_groups
        @total_groups ||= YAML.load(ERB.new(File.read("#{structures}/invest_result_total.yml")).result(binding))
      end

      def month
        @month ||= date_end.to_date.month
      end

      def default_params
        @default_params ||= {
          begin_date: date_begin.to_date,
          end_date: date_end.to_date,
          gkpz_year: gkpz_year.to_i
        }.with_indifferent_access
      end

      def total_rows(filter)
        summary_array = %w(count_lots gkpz_cost gkpz_cost_nds s_cost s_cost_nds winner_final_cost winner_final_cost_nds)
        part1_sql_rows.select do |r|
          filter.all? { |k, v| (v ? Array(v).include?(r[k.to_s]) : true) } && r['rn'] == 1
        end.inject({}) do |h1, h2|
          h1.merge(h2) do |key, old_val, new_val|
            next if summary_array.exclude?(key)
            old_val + (new_val || 0.0)
          end
        end.with_indifferent_access
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

      # TOTAL_ROWS = {
      #   row1: { name: row_title('ks_services'), directions: Direction::KS, subj_type: SubjectType::SERVICES },
      #   row2: { name: row_title('ks_material'), directions: Direction::KS, subj_type: SubjectType::MATERIALS },
      #   row3: { name: row_title('ks'), directions: Direction::KS },
      #   row4: { name: row_title('tpir_services'), directions: Direction::TPIR, subj_type: SubjectType::SERVICES },
      #   row5: { name: row_title('tpir_material'), directions: Direction::TPIR, subj_type: SubjectType::MATERIALS },
      #   row6: { name: row_title('tpir'), directions: Direction::TPIR },
      #   row7: { name: row_title('it_services'), directions: Direction::IT_INVEST, subj_type: SubjectType::SERVICES },
      #   row8: { name: row_title('it_material'), directions: Direction::IT_INVEST, subj_type: SubjectType::MATERIALS },
      #   row9: { name: row_title('it'), directions: Direction::IT_INVEST },
      #   row10: {
      #     name: row_title('niokr_services'), directions: Direction::NIOKR_INVEST, subj_type: SubjectType::SERVICES
      #   },
      #   row11: {
      #     name: row_title('niokr_material'), directions: Direction::NIOKR_INVEST, subj_type: SubjectType::MATERIALS
      #   },
      #   row12: { name: row_title('niokr'), directions: Direction::NIOKR_INVEST },
      #   row13: {
      #     name: row_title('ipivp_services'), directions: Direction::IPIVP_INVEST, subj_type: SubjectType::SERVICES
      #   },
      #   row14: {
      #     name: row_title('ipivp_material'), directions: Direction::IPIVP_INVEST, subj_type: SubjectType::MATERIALS
      #   },
      #   row15: { name: row_title('ipivp'), directions: Direction::IPIVP_INVEST },
      #   row16: { name: row_title('services'), subj_type: SubjectType::SERVICES },
      #   row17: { name: row_title('material'), subj_type: SubjectType::MATERIALS },
      #   row18: { name: row_title('summary') }
      # }

      TOTAL_COLUMNS = {
        c1: { type: :integer, style: :td, value: ->(r) { r['count_lots'] }, width: 15 },
        c2: { type: :float, style: :td_money, value: ->(r) { r['gkpz_cost'] }, width: 20 },
        c3: { type: :float, style: :td_money, value: ->(r) { r['gkpz_cost_nds'] }, width: 20 },
        c4: { type: :float, style: :td_money, value: ->(r) { r['s_cost'] }, width: 20 },
        c5: { type: :float, style: :td_money, value: ->(r) { r['s_cost_nds'] }, width: 20 },
        c6: { type: :float, style: :td_money, value: ->(r) { r['winner_final_cost'] }, width: 20 },
        c7: { type: :float, style: :td_money, value: ->(r) { r['winner_final_cost_nds'] }, width: 20 }
      }

      COLUMNS = {
        c1: { type: :integer, style: :td, width: 05, part2: true, part3: true },
        c2: {
          type: :string, style: :td, value: ->(r) { r['root_customer_name'] }, width: 25, part2: true, part3: true
        },
        c3: {
          type: :string, style: :td, value: ->(r) { r['invest_project_name'] }, width: 25, part2: true, part3: true
        },
        c4: {
          type: :string, style: :td, value: ->(r) { r['invest_object_name'] }, width: 25, part2: true, part3: true
        },
        c5: {
          type: :date, style: :td_date, value: ->(r) { r['date_install'].try(:to_date) }, width: 15, part2: true,
          part3: true
        },
        c6: {
          type: :string, style: :td, width: 15, part2: true, part3: true,
          value: (lambda do |r|
            [
              r['power_elec_gen'] && [r['power_elec_gen'], ' МВт'].join,
              r['power_thermal_gen'] && [r['power_thermal_gen'], ' ГКал/ч'].join,
              r['power_elec_net'] && [r['power_elec_net'], ' км'].join,
              r['power_thermal_net'] && [r['power_thermal_net'], ' км'].join,
              r['power_substation'] && [r['power_substation'], ' МВА'].join
            ].compact.join('; ')
          end)
        },
        c7: { type: :string, style: :td, value: ->(r) { r['lot_name'].strip }, width: 60, part2: true, part3: true },
        c8: { type: :string, style: :td_right, value: ->(r) { r['lot_num'] }, width: 15, part2: true, part3: true },
        c9: { type: :string, style: :td, value: ->(r) { r['lot_state'] }, width: 15, part2: true, part3: true },
        c10: { type: :string, style: :td, value: ->(r) { r['org_name'] }, width: 40, part2: true, part3: true },
        c11: { type: :string, style: :td, value: ->(r) { r['ctype_name'] }, width: 15, part2: true, part3: true },
        c11_1: { type: :string, style: :td, value: ->(r) { r['sme_type_name'] }, width: 30, part2: true, part3: true },
        c12: { type: :string, style: :td, value: ->(r) { r['gkpz_ttype_name'] }, width: 15, part2: true, part3: true },
        c13: { type: :string, style: :td, value: ->(r) { r['fact_ttype_name'] }, width: 15, part2: true },
        c14: { type: :string, style: :td, value: ->(r) { r['fact_ei'] }, width: 15 },
        c15: {
          type: :float, style: :td_money, value: ->(r) { r['gkpz_cost_nds'] }, sum: true,
          width: 20, part2: true, part3: true
        },
        c16: { type: :string, style: :td, value: ->(r) { r['cost_doc'] }, width: 40, part2: true, part3: true },
        c17: { type: :float, style: :td_money, value: ->(r) { r['s_cost_nds'] }, sum: true, width: 20, part2: true },
        c18: { type: :float, style: :td_money, value: ->(r) { r['gkpz_amount_finance_nds'] }, width: 20, part2: true },
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
        c23: {
          type: :string, style: :td, value: ->(r) { r['non_public_reason'].try(:strip) }, width: 60,
          part2: true, part3: true
        },
        c24: {
          type: :date, style: :td_date, value: ->(r) { r['protocol_date_plan'].try(:getlocal, Time.zone.utc_offset).try(:to_date) },
          width: 15
        },
        c25: { type: :date, style: :td_date, value: ->(r) { r['wp_confirm_date'].try(:to_date) }, width: 15 },
        c26: { type: :integer, style: :td, value: ->(r) { r['registred_bidders_count'] }, width: 15 },
        c27: { type: :integer, style: :td, value: ->(r) { r['cnt_offers'] }, width: 15 },
        c28: { type: :string, style: :td, no_merge: true, value: ->(r) { r['contr_name'] }, width: 60 },
        c29: {
          type: :float, style: :td_money, no_merge: true, value: ->(r) { r['bid_cost_nds'] }, width: 20
        },
        c30: { type: :float, style: :td_money, value: ->(r) { r['average_cost'] }, sum: true, width: 20 },
        c31: { type: :string, style: :td, no_merge: true, value: ->(r) { r['bid_reject_name'] }, width: 60 },
        c32: { type: :string, style: :td_center, value: ->(r) { r['rebid'] ? '+' : '-' }, width: 15 },
        c33: {
          type: :float, style: :td_money, no_merge: true, value: ->(r) { r['bid_final_cost_nds'] if r['rebid'] },
          width: 20
        },
        c34: { type: :string, style: :td_center, value: ->(r) { r['rebid_count'] }, width: 15 },
        c35: {
          type: :float, style: :td_money, no_merge: true, value: ->(r) { r['winner_cost_nds'] if r['rebid'] },
          sum: true, width: 20
        },
        c36: {
          type: :float, style: :td_money, no_merge: true, value: ->(r) { r['winner_final_cost_nds'] }, sum: true,
          width: 20
        },
        c37: {
          type: :string, style: :td, no_merge: true, value: ->(r) { r['bid_winner_name'] }, width: 60, part2: true
        },
        c38: { type: :float, style: :td_money, value: ->(r) { (c15(r) || 0) - (c36(r) || 0) }, sum: true, width: 20 },
        c39: {
          type: :float, style: :td_percent, value: ->(r) { c15(r).to_f == 0 ? nil : c38(r) / c15(r).to_f }, width: 15,
          sum: true, sum_value: ->(g) { g["c15_total"] == 0 ? nil : g["c38_total"] / g["c15_total"].to_f },
          sum_style: :sum_percent, persent_formula: { numerator: 38, denomenator: 15 } },
        c40: { type: :float, style: :td_money, value: ->(r) { c17(r) - (c36(r) || 0) }, sum: true, width: 20 },
        c41: {
          type: :float, style: :td_percent, value: ->(r) { c17(r) == 0 ? nil : c40(r) / c17(r).to_f }, width: 15,
          sum: true, sum_value: ->(g) { g["c17_total"] == 0 ? nil : g["c40_total"] / g["c17_total"].to_f },
          sum_style: :sum_percent, persent_formula: { numerator: 40, denomenator: 17 }
        },
        c42: {
          type: :float, style: :td_money, value: ->(r) { (c35(r) || 0) - (c36(r) || 0) if r['rebid'] },
          sum: true, width: 20
        },
        c43: {
          type: :float, style: :td_percent, value: ->(r) { ((c35(r) || 0) == 0 ? nil : c42(r) / c35(r).to_f) if r['rebid'] },
          width: 15,
          sum: true, sum_value: ->(g) { g["c35_total"] == 0 ? nil : g["c42_total"] / g["c35_total"].to_f },
          sum_style: :sum_percent, persent_formula: { numerator: 42, denomenator: 35 }
        },
        c44: { type: :float, style: :td_money, value: ->(r) { c30(r) - (c36(r) || 0) }, sum: true, width: 20 },
        c45: {
          type: :float, style: :td_percent, value: ->(r) { c30(r) == 0 ? nil : c44(r) / c30(r).to_f }, width: 15,
          sum: true, sum_value: ->(g) { g["c30_total"] == 0 ? nil : g["c44_total"] / g["c30_total"].to_f },
          sum_style: :sum_percent, persent_formula: { numerator: 44, denomenator: 30 }
        },
        c46: { type: :date, style: :td_date, value: ->(r) { r['plan_contract_date'].try(:to_date) }, width: 15 },
        c47: { type: :date, style: :td_date, value: ->(r) { r['contract_confirm_date'].try(:to_date) }, width: 15 },
        c48: {
          type: :string, style: :td, value: ->(r) { r['non_contract_reason'] }, width: 30
        },
        c49: { type: :float, style: :td_money, value: ->(r) { r['contract_spec_cost_nds'] }, sum: true, width: 20 },
        c50: { type: :string, style: :td_right, value: ->(r) { r['etp_num'] }, width: 15 },
        c51: { type: :string, style: :td, value: ->(r) { c50(r) ? r['etp_address'] : nil }, width: 17 },
        c52: { type: :string, style: :td_right, value: ->(r) { r['regulation_item_num'] }, width: 20 },
        c53: { type: :string, style: :td_right, value: ->(r) { r['responcible_dept'] }, width: 20 },
        c54: { type: :string, style: :td_right, value: ->(r) { r['order_date'].try(:to_date) }, width: 15 },
        c55: { type: :string, style: :td_right, value: ->(r) { r['order_num'] }, width: 15 },
        c56: {
          type: :string, style: :td_right, value: ->(r) { r['gkpz_delivery_date_begin'].try(:to_date) }, width: 15
        },
        c57: {
          type: :string, style: :td_right, value: ->(r) { r['contract_delivery_date_begin'].try(:to_date) }, width: 15
        },
        c58: {
          type: :string, style: :td_right, value: ->(r) { r['contract_delivery_date_end'].try(:to_date) }, width: 15
        },

        # c59: { type: :string, style: :td, value: ->(r) { r['is_sme'] }, width: 30 },
        # c60: { type: :float, style: :td_money, value: ->(r) { c59(r) ? c49(r) : nil }, sum: true, width: 30 },
        # c61: {
        #   type: :float, style: :td_percent, value: ->(r) { c60(r) ? 1.0 : nil }, width: 30,
        #   sum: true, sum_value: ->(g) { g["c49_total"] == 0 ? nil : g["c60_total"] / g["c49_total"].to_f },
        #   sum_style: :sum_percent
        # },
        # c62: { type: :string, style: :td, value: ->(r) { c63(r) > 0 ? 'МСП' : nil }, width: 30 },
        # c63: { type: :integer, style: :td, value: ->(r) { r['sub_cnt'] }, width: 30 },
        # c64: { type: :float, style: :td_money, value: ->(r) { r['sub_cost_nds'] || 0 }, sum: true, width: 30 },
        # c65: {
        #   type: :float, style: :td_percent, value: ->(r) { c49(r) && c49(r) != 0 ? c64(r) / c49(r).to_f : nil },
        #   width: 30,
        #   sum: true, sum_value: ->(g) { g["c49_total"] == 0 ? nil : g["c64_total"] / g["c49_total"].to_f },
        #   sum_style: :sum_percent
        # },
        # c66: {
        #   type: :float, style: :td_money,
        #   value: (lambda do |r|
        #     return c60(r) if c59(r) == 'МСП'
        #     return c64(r) if c62(r) == 'МСП'
        #     0
        #   end),
        #   sum: true, width: 30
        # },
        # c67: {
        #   type: :float, style: :td_percent, value: ->(r) { c49(r) && c49(r) != 0 ? c66(r) / c49(r) : nil }, width: 30,
        #   sum: true, sum_value: ->(g) { g["c49_total"] == 0 ? nil : g["c66_total"] / g["c49_total"] },
        #   sum_style: :sum_percent
        # }
        # c56: {
        #   type: :string, style: :td_right, value: ->(r) { }, width: 15
        # },
        # c57: {
        #   type: :string, style: :td_right, value: ->(r) { }, width: 15
        # },
        # c58: {
        #   type: :string, style: :td_right, value: ->(r) { }, width: 15
        # },

        c59: { type: :string, style: :td, value: ->(r) { }, width: 30 },
        c60: { type: :float, style: :td_money, value: ->(r) { }, sum: true, width: 30 },
        c61: {
          type: :float, style: :td_percent, value: ->(r) { }, width: 30,
          sum: true, sum_value: ->(g) { },
          sum_style: :sum_percent
        },
        c62: { type: :string, style: :td, value: ->(r) { }, width: 30 },
        c63: { type: :integer, style: :td, value: ->(r) { }, width: 30 },
        c64: { type: :float, style: :td_money, value: ->(r) { }, sum: true, width: 30 },
        c65: {
          type: :float, style: :td_percent, value: ->(r) { },
          width: 30,
          sum: true, sum_value: ->(g) { },
          sum_style: :sum_percent
        },
        c66: {
          type: :float, style: :td_money,
          value: ->(r) { },
          sum: true, width: 30
        },
        c67: {
          type: :float, style: :td_percent, value: ->(r) { }, width: 30,
          sum: true, sum_value: ->(g) { },
          sum_style: :sum_percent
        }
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

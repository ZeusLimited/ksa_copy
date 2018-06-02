module Reports
  module Reglament
    class InvestSession < Reports::Base
      class TotalRow
        attr_accessor :name, :public_cost_nds, :winner_cost_nds, :lot_count, :fact_lot_count, :gkpz_cost_nds

        def initialize(params, name = nil)
          self.name = name || params['name']
          self.public_cost_nds = params['public_cost_nds']
          self.winner_cost_nds = params['winner_cost_nds']
          self.gkpz_cost_nds = params['gkpz_cost_nds']
          self.lot_count = params['lot_count']
          self.fact_lot_count = params['fact_lot_count']
        end

        def self.sum_rows(name, row1, row2)
          new('name' => name,
              'public_cost_nds' => ((row1.public_cost_nds || 0) + (row2.public_cost_nds || 0)),
              'winner_cost_nds' => ((row1.winner_cost_nds || 0) + (row2.winner_cost_nds || 0)),
              'gkpz_cost_nds' => ((row1.gkpz_cost_nds || 0) + (row2.gkpz_cost_nds || 0)),
              'lot_count' => ((row1.lot_count || 0) + (row2.lot_count || 0)),
              'fact_lot_count' => ((row1.fact_lot_count || 0) + (row2.fact_lot_count || 0))
          )
        end

        def self.sum(name, rows)
          new('name' => name,
              'public_cost_nds' => rows.sum(&:public_cost_nds),
              'winner_cost_nds' => rows.sum(&:winner_cost_nds),
              'gkpz_cost_nds' => rows.sum { |r| r.gkpz_cost_nds || 0 } ,
              'lot_count' => rows.sum(&:lot_count),
              'fact_lot_count' => rows.sum(&:fact_lot_count)
          )
        end
      end

      def groups
        @groups ||= YAML.load(ERB.new(File.read("#{structures}/high_tech_result.yml")).result(binding))
      end

      def default_params
        @default_params ||= {
          begin_date: date_begin.to_date,
          end_date: date_end.to_date,
          subject_type: -1,
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

      def total_by_type_rows(custs)
        # total_by_type_sql_rows
        customers = Department.subtree_ids_for(custs)
        select_all(sanitize_sql([total_by_type, default_params.merge(customers: customers)]))
      end

      def total_rows
        self.customers = Department.roots.pluck(:id) unless customers
        object = {}

        # По способам
        object[:group1] = { title: nil, rows: [] }

        total_by_type_rows(customers).each do |row|
          object[:group1][:rows] << TotalRow.new(row)
        end
        object[:group1][:rows] << TotalRow.sum('Итого:', object[:group1][:rows])

        customers.each do |cust|
          group_name = "cust_#{cust}".to_sym
          object["cust_#{cust}".to_sym] = { title: Department.find(cust).name, rows: [] }
          total_by_type_rows([cust]).each do |row|
            object[group_name][:rows] << TotalRow.new(row)
          end
          object[group_name][:rows] << TotalRow.sum('Итого:', object[group_name][:rows])
        end

        object
      end

      # types = [:date, :time, :float, :integer, :string, :boolean]

      TOTAL_COLUMNS = {
        c1: { type: :string, style: :td, value: ->(r) { r.name }, width: 40 },
        c2: { type: :integer, style: :td, value: ->(r) { r.lot_count }, width: 10 },
        c3: { type: :float, style: :td_money, value: ->(r) { to_thousand(r.gkpz_cost_nds) }, width: 20 },
        c4: { type: :integer, style: :td, value: ->(r) { r.fact_lot_count }, width: 10 },
        c5: { type: :float, style: :td_money, value: ->(r) { to_thousand(r.public_cost_nds) }, width: 20 },
        c6: { type: :float, style: :td_money, value: ->(r) { to_thousand(r.winner_cost_nds) }, width: 20 }
      }

      COLUMNS = {
        c1: { type: :integer, style: :td, width: 05, part2: true, part3: true },
        c1_1: { type: :string, style: :td, value: ->(r) { r['cust_name'] }, width: 40, part2: true, part3: true },
        c2: { type: :string, style: :td_right, value: ->(r) { r['lot_num'] }, width: 15, part2: true, part3: true },
        c3: { type: :string, style: :td, value: ->(r) { r['lot_name'].strip }, width: 60, part2: true, part3: true },
        c4: { type: :string, style: :td, value: ->(r) { r['lot_state'] }, width: 15, part2: true, part3: true },
        c5: { type: :string, style: :td, value: ->(r) { r['org_name'] }, width: 40, part2: true, part3: true },
        c6: { type: :string, style: :td, value: ->(r) { r['ctype_name'] }, width: 15, part2: true, part3: true },
        c7: {
          type: :float, style: :td_money, value: ->(r) { r['gkpz_cost_nds'] }, sum: true,
          width: 20, part2: true, part3: true
        },
        c7_1: { type: :string, style: :td, value: ->(r) { r['sme_type_name'] }, width: 30, part2: true, part3: true },
        c8: { type: :float, style: :td_money, value: ->(r) { r['public_cost_nds'] }, sum: true, width: 20, part2: true },
        c9: { type: :string, style: :td, value: ->(r) { r['gkpz_ttype_name'] }, width: 15, part2: true, part3: true },
        c10: { type: :string, style: :td, value: ->(r) { r['fact_ttype_name'] }, width: 15, part2: true },
        c11: { type: :string, style: :td, value: ->(r) { r['fact_ei'] }, width: 15, part2: true },
        c12: {
          type: :date, style: :td_date, value: ->(r) { r['gkpz_announce_date'].try(:to_date) },
          width: 15, part2: true, part3: true
        },
        c13: {
          type: :date, style: :td_date, value: ->(r) { r['fact_announce_date'].try(:to_date) }, width: 15, part2: true
        },
        c14: {
          type: :date, style: :td_date, value: ->(r) { r['op_open_date'].try(:getlocal, Time.zone.utc_offset).try(:to_date) }, width: 15,
          part2: true
        },
        c15: { type: :integer, style: :td, value: ->(r) { r['cnt_offers'] }, width: 15 },
        c16: { type: :string, style: :td, no_merge: true, value: ->(r) { r['contr_name'] }, width: 60 },
        c17: {
          type: :float, style: :td_money, no_merge: true, value: ->(r) { r['bid_cost_nds'] }, width: 20
        },
        c18: { type: :string, style: :td, no_merge: true, value: ->(r) { r['bid_reject_name'] }, width: 60 },
        c19: { type: :float, style: :td_money, value: ->(r) { r['average_cost'] }, sum: true, width: 20 },
        c19_1: { type: :string, style: :td_center, value: ->(r) { r['rebid'] }, width: 15 },
        c19_2: {
          type: :float, style: :td_money, no_merge: true, value: ->(r) { r['bid_final_cost_nds'] }, width: 20
        },
        c20: {
          type: :string, style: :td, no_merge: true, value: ->(r) { r['bid_winner_name'] }, width: 60, part2: true
        },
        c21: {
          type: :float, style: :td_money, no_merge: true, value: ->(r) { r['winner_cost_nds'] }, sum: true, width: 20
        },
        c22: { type: :date, style: :td_date, value: ->(r) { r['wp_confirm_date'].try(:to_date) }, width: 15 },
        c23: { type: :float, style: :td_money, value: ->(r) { (c7(r) || 0) - (c21(r) || 0) }, sum: true, width: 20 },
        c24: {
          type: :float, style: :td_percent, value: ->(r) { c7(r).to_f == 0 ? nil : c23(r) / c7(r).to_f }, width: 15,
          sum: true, sum_value: ->(g) { g["c7_total"] == 0 ? nil : g["c23_total"] / g["c7_total"].to_f },
          sum_style: :sum_percent },
        c25: { type: :float, style: :td_money, value: ->(r) { c8(r) - (c21(r) || 0) }, sum: true, width: 20 },
        c26: {
          type: :float, style: :td_percent, value: ->(r) { c8(r) == 0 ? nil : c25(r) / c8(r).to_f }, width: 15,
          sum: true, sum_value: ->(g) { g["c8_total"] == 0 ? nil : g["c25_total"] / g["c8_total"].to_f },
          sum_style: :sum_percent
        },
        c27: { type: :float, style: :td_money, value: ->(r) { c19(r) - (c21(r) || 0) }, sum: true, width: 20 },
        c28: {
          type: :float, style: :td_percent, value: ->(r) { c19(r) == 0 ? nil : c27(r) / c19(r).to_f }, width: 15,
          sum: true, sum_value: ->(g) { g["c19_total"] == 0 ? nil : g["c27_total"] / g["c19_total"].to_f },
          sum_style: :sum_percent
        },
        c29: { type: :string, style: :td, value: ->(r) { r['contract_status'] }, width: 30, part2: true, part3: true },
        c30: { type: :date, style: :td_date, value: ->(r) { r['plan_contract_date'].try(:to_date) }, width: 15 },
        c31: { type: :date, style: :td_date, value: ->(r) { r['contract_confirm_date'].try(:to_date) }, width: 15 },
        c32: { type: :float, style: :td_money, value: ->(r) { r['contract_spec_cost_nds'] }, sum: true, width: 20 },
        c33: { type: :string, style: :td, value: ->(r) { r['is_sme'] }, width: 30 },
        c34: { type: :float, style: :td_money, value: ->(r) { c33(r) ? c32(r) : nil }, sum: true, width: 30 },
        c35: {
          type: :float, style: :td_percent, value: ->(r) { c33(r) ? 1.0 : nil }, width: 30,
          sum: true, sum_value: ->(g) { g["c32_total"] == 0 ? nil : g["c34_total"] / g["c32_total"].to_f },
          sum_style: :sum_percent
        },
        c36: { type: :string, style: :td, value: ->(r) { c37(r) > 0 ? 'МСП' : nil }, width: 30 },
        c37: { type: :integer, style: :td, value: ->(r) { r['sub_cnt'] }, width: 30 },
        c38: { type: :float, style: :td_money, value: ->(r) { r['sub_cost_nds'] || 0 }, sum: true, width: 30 },
        c39: {
          type: :float, style: :td_percent, value: ->(r) { c32(r) && c32(r) != 0 ? c38(r) / c32(r).to_f : nil },
          width: 30,
          sum: true, sum_value: ->(g) { g["c32_total"] == 0 ? nil : g["c38_total"] / g["c32_total"].to_f },
          sum_style: :sum_percent
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
          sum_style: :sum_percent
        },
        c42: { type: :string, style: :td, value: ->(r) { r['life_cycle'] }, width: 10 },
        c43: { type: :string, style: :td, value: ->(r) { r['regulation_item_num'] }, width: 10 }
      }

      COLUMNS.each_pair do |ckey, cval|
        define_singleton_method(ckey) { |r| cval[:value].call(r) }
      end
    end
  end
end

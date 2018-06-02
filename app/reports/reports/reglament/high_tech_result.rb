module Reports
  module Reglament
    class HighTechResult < Reports::Base
      attr_accessor :show_root

      class TotalRow
        attr_accessor :name, :public_cost_nds, :winner_cost_nds, :lot_count, :spec_count

        def initialize(params, name = nil)
          params ||= {}
          self.name = name || params['fact_ttype_name']
          self.public_cost_nds = params['s_cost_nds'] || params['gkpz_cost_nds']
          self.winner_cost_nds = params['winner_cost_nds']
          self.lot_count = params['lot_count']
          self.spec_count = params['spec_count']
        end

        def self.sum_rows(name, row1, row2)
          new('fact_ttype_name' => name,
              's_cost_nds' => ((row1.public_cost_nds || 0) + (row2.public_cost_nds || 0)),
              'winner_cost_nds' => ((row1.winner_cost_nds || 0) + (row2.winner_cost_nds || 0)),
              'lot_count' => ((row1.lot_count || 0) + (row2.lot_count || 0)),
              'spec_count' => ((row1.spec_count || 0) + (row2.spec_count || 0))
          )
        end

        def self.sum(name, rows)
          new('fact_ttype_name' => name,
              's_cost_nds' => rows.sum(&:public_cost_nds),
              'winner_cost_nds' => rows.sum { |r| r.winner_cost_nds || 0 },
              'lot_count' => rows.sum(&:lot_count),
              'spec_count' => rows.sum(&:spec_count)
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

      def total_by_type_rows
        part1_sql_rows.select { |r| r['rn'] == 1 }.group_by { |r| r['fact_ttype_name'] }.map do |_, v|
          v.inject do |h1, h2|
            h1.merge(h2) do |k, o, n|
              %(s_cost_nds winner_cost_nds lot_count spec_count).include?(k) ? o + (n || 0) : o
            end
          end
        end
      end

      def total_by_type_eu_rows
        part1_sql_rows.select { |r| r['rn'] == 1 && r['fact_ei'] == 'ЕУ' }.inject do |h1, h2|
          h1.merge(h2) do |k, o, n|
            %(s_cost_nds winner_cost_nds lot_count spec_count).include?(k) ? o + (n || 0) : o
          end
        end
      end

      def total_public_rows(filter)
        part2_rows(filter).inject do |h1, h2|
          h1.merge(h2) do |k, o, n|
            %(s_cost_nds lot_count spec_count).include?(k) ? o + (n || 0) : o
          end
        end
      end

      def total_confirm_rows(filter)
        part1_rows(filter).select { |r| r['rn'] == 1 }.inject do |h1, h2|
          h1.merge(h2) do |k, o, n|
            %(s_cost_nds winner_cost_nds lot_count spec_count).include?(k) ? o + (n || 0) : o
          end
        end
      end

      def total_not_public_rows(filter)
        part3_rows(filter).inject do |h1, h2|
          h1.merge(h2) do |k, o, n|
            %(gkpz_cost_nds lot_count spec_count).include?(k) ? o + (n || 0) : o
          end
        end
      end

      def total_cancelled_rows(filter = {})
        total_cancelled_sql_rows.select do |r|
          filter.all? { |k, v| Array(v).include?(r[k.to_s]) }
        end.inject do |h1, h2|
          h1.merge(h2) do |k, o, n|
            %(gkpz_cost_nds lot_count spec_count).include?(k) ? o + (n || 0) : o
          end
        end
      end

      def total_public_by_type_rows
        part2_sql_rows.group_by { |r| r["fact_ttype_name"] }.map do |_, v|
          v.inject do |h1, h2|
            h1.merge(h2) do |k, o, n|
              %(s_cost_nds, lot_count, spec_count winner_cost_nds).include?(k) ? o + (n || 0) : o
            end
          end
        end
      end

      def total_rows
        object = {
          group1: {
            title: nil,
            rows: []
          },
          group2: {
            title: 'ИТОГО, в .т.ч',
            rows: []
          },
          group3: {
            title: 'ВСЕГО ОБЪЯВЛЕНО ЗАКУПОК',
            rows: []
          },
          group4: {
            title: 'ВНЕПЛАНОВЫЕ ЗАКУПКИ',
            rows: []
          },
          group5: {
            title: 'ПЛАН НА ОТЧЕТНЫЙ ПЕРИОД ПО ГКПЗ С УЧЕТОМ ЦЗК',
            rows: []
          },
          group6: {
            title: 'НЕОБЪЯВЛЕННЫЕ С УЧЕТОМ ВСЕХ РЕШЕНИЙ ЦЗК',
            rows: []
          },
          group7: {
            title: 'ОБЪЯВЛЕНЫ, НО ИТОГИ НЕ ПОДВЕДЕНЫ',
            rows: []
          }
        }
        name_rg = 'Регламентированные закупки'
        name_nz = 'Нерегламентированные закупки'
        # По способам
        total_by_type_rows.each do |row|
          object[:group1][:rows] << TotalRow.new(row)
        end
        # Итого
        confirm_rg = TotalRow.sum(name_rg, object[:group1][:rows].select { |l| l.name != 'НЗ' })
        confirm_nz = TotalRow.sum(name_nz, object[:group1][:rows].select { |l| l.name == 'НЗ' })
        object[:group2][:rows] << confirm_rg
        object[:group2][:rows] << confirm_nz
        object[:group2][:rows] << TotalRow.new(total_by_type_eu_rows, 'в т.ч. ЕУ по результатам конкурсных процедур')
        # Всего объявлено
        public_rg = TotalRow.new(total_public_rows(tender_type_id: TenderTypes::REGULATED), name_rg)
        public_nz = TotalRow.new(total_public_rows(tender_type_id: TenderTypes::UNREGULATED), name_nz)
        object[:group3][:rows] << TotalRow.sum_rows(name_rg, public_rg, confirm_rg)
        object[:group3][:rows] << TotalRow.sum_rows(name_nz, public_nz, confirm_nz)
        # Внеплановые закупки
        object[:group4][:rows] << TotalRow.new(total_confirm_rows({ tender_type_id: TenderTypes::REGULATED, state_in_plan: 0 }), name_rg)
        object[:group4][:rows] << TotalRow.new(total_confirm_rows({ tender_type_id: TenderTypes::UNREGULATED, state_in_plan: 0 }), name_nz)
        public_rg_vz = TotalRow.new(total_public_rows({ tender_type_id: TenderTypes::REGULATED, state_in_plan: 0 }), 'Регламентированные не подвед. итоги')
        public_nz_vz = TotalRow.new(total_public_rows({ tender_type_id: TenderTypes::UNREGULATED, state_in_plan: 0 }), 'Нерегламентированные не подвед. итоги')
        object[:group4][:rows] << public_rg_vz
        object[:group4][:rows] << public_nz_vz
        object[:group4][:rows] << TotalRow.new(total_not_public_rows({ tender_type_id: TenderTypes::REGULATED, state_in_plan: 0 }), 'Необъявленные регламентированные')
        object[:group4][:rows] << TotalRow.new(total_not_public_rows({ tender_type_id: TenderTypes::UNREGULATED, state_in_plan: 0 }), 'Необъявленные нерегламентированные')
        # # ПЛАН На отчетный период по ГКПЗ с учетом ЦЗК
        object[:group5][:rows] << TotalRow.sum('Состоявшиеся закупки', object[:group1][:rows])
        object[:group5][:rows] << TotalRow.sum_rows('Закупки с неподведенными итогами', public_rg, public_nz)
        object[:group5][:rows] << TotalRow.new(total_not_public_rows({}), 'Необъявленные')
        object[:group5][:rows] << TotalRow.new(total_confirm_rows(etp_address_id: Constants::EtpAddress::ETP),
                                               'Фактически объявленные на ЭТП из состоявшихся')
        object[:group5][:rows] << TotalRow.new(total_confirm_rows(tender_type_id: Constants::TenderTypes::AUCTIONS),
                                               'Фактически объявленные аукционы из состоявшихся')
        object[:group5][:rows] << TotalRow.new(total_cancelled_rows,
                                               'Отмененные, в т.ч. решениями ЦЗК, за выбранный период')
        object[:group5][:rows] << TotalRow.new(total_cancelled_rows(tender_type_id: TenderTypes::REGULATED),
                                               'в т.ч. регламентированные отмененные')
        object[:group5][:rows] << TotalRow.new(total_cancelled_rows(tender_type_id: TenderTypes::UNREGULATED),
                                               'в т.ч. нерегламентированные отмененные')
        object[:group5][:rows] << TotalRow.new(total_confirm_rows(regulation_item_num: '5.9.1.4'),
                                               'ЕИ по п.5.9.1.4')
        total_not_public_czk_sql_rows.each do |row|
          object[:group6][:rows] << TotalRow.new(row)
        end
        object[:group6][:rows].insert(0, TotalRow.sum('Всего', object[:group6][:rows]))

        total_public_by_type_rows.each do |row|
          object[:group7][:rows] << TotalRow.new(row)
        end
        object[:group7][:rows].insert(0, TotalRow.sum('Всего', object[:group7][:rows]))

        object
      end

      # types = [:date, :time, :float, :integer, :string, :boolean]

      TOTAL_COLUMNS = {
        c1: { type: :string, style: :td, value: ->(r) { r.name }, width: 40 },
        c2: { type: :float, style: :td_money, value: ->(r) { to_thousand(r.public_cost_nds) }, width: 20 },
        c3: { type: :float, style: :td_money, value: ->(r) { to_thousand(r.winner_cost_nds) }, width: 20 },
        c4: { type: :integer, style: :td, value: ->(r) { r.lot_count }, width: 10 },
        c5: { type: :integer, style: :td, value: ->(r) { r.spec_count }, width: 10 }
      }

      COLUMNS = {
        consumer_name: { type: :string, style: :td, value: ->(r) { r['root_customer_name'] }, width: 30, part2: true, part3: true },
        c1: { type: :integer, style: :td, width: 05, part2: true, part3: true },
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
        c8: { type: :float, style: :td_money, value: ->(r) { r['s_cost_nds'] }, sum: true, width: 20, part2: true },
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
        c19_1: { type: :string, style: :td_center, value: ->(r) { r['rebid'] ? '+' : '-' }, width: 15 },
        c19_2: {
          type: :float, style: :td_money, no_merge: true, value: ->(r) { r['bid_final_cost_nds'] if r['rebid'] }, width: 20
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
          sum_style: :sum_percent, persent_formula: { numerator: 25, denomenator: 6 } },
        c25: { type: :float, style: :td_money, value: ->(r) { c8(r) - (c21(r) || 0) }, sum: true, width: 20 },
        c26: {
          type: :float, style: :td_percent, value: ->(r) { c8(r) == 0 ? nil : c25(r) / c8(r).to_f }, width: 15,
          sum: true, sum_value: ->(g) { g["c8_total"] == 0 ? nil : g["c25_total"] / g["c8_total"].to_f },
          sum_style: :sum_percent, persent_formula: { numerator: 27, denomenator: 8 }
        },
        c27: { type: :float, style: :td_money, value: ->(r) { c19(r) - (c21(r) || 0) }, sum: true, width: 20 },
        c28: {
          type: :float, style: :td_percent, value: ->(r) { c19(r) == 0 ? nil : c27(r) / c19(r).to_f }, width: 15,
          sum: true, sum_value: ->(g) { g["c19_total"] == 0 ? nil : g["c27_total"] / g["c19_total"].to_f },
          sum_style: :sum_percent, persent_formula: { numerator: 29, denomenator: 19 }
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
        c42: { type: :string, style: :td, value: ->(r) { r['life_cycle'] }, width: 10 }
      }

      COLUMNS.each_pair do |ckey, cval|
        define_singleton_method(ckey) { |r| cval[:value].call(r) }
      end
    end
  end
end

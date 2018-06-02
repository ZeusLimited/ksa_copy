module Reports
  module Other
    class ExpectedEconomicEffect < Reports::Base

      def groups
        @groups ||= YAML.load(ERB.new(File.read("#{structures}/gkpz.yml")).result(binding))
      end

      def default_params
        @default_params ||= {
          begin_date: date_begin.to_date,
          end_date: date_end.to_date,
          gkpz_year: gkpz_year.to_i,
          direction_id: -1,
          subject_type_id: -1
        }.with_indifferent_access
      end

      def result_rows(filter)
        general_sql_rows.select do |row|
          filter.all? { |k, v| Array(v).include?(row[k.to_s]) }
        end.sort_by { |r| r['sort_order'] }
      end

      TOT_COLUMNS = {
        c1: { col: 'A', type: :string, style: :td, value: ->(r) { r['tender_type'] }, width: 40 },
        c2: { col: 'B', type: :float, style: :td_money, value: ->(r) { r['gkpz_cost'] }, sum: true, width: 15 },
        c3: { col: 'C', type: :float, style: :td_money, value: ->(r) { r['winner_cost'] }, sum: true, width: 15 },
        c4: {
          col: 'D', type: :string, style: :td_money,
          formula: ->(i) { %[=IF(C#{i},B#{i}-C#{i},"")] }, sum: true, sum_formula: true, width: 15
        },
        c5: {
          col: 'E', type: :string, style: :td_percent,
          formula: ->(i) { %[=IF(C#{i},(B#{i}-C#{i})/B#{i},"")] }, sum: true, sum_formula: true, width: 10
        },
        c6: {
          col: 'F', type: :float, style: :td_money, value: ->(r) { r['contract_cost'] }, sum: true, width: 15
        },
        c7: { col: 'G', type: :integer, style: :td, value: ->(r) { r['count_lots'] }, sum: true, width: 10 }
      }

      GEN_COLUMNS = {
        c1: { col: 'A', type: :string, style: :td, value: ->(r) { r['tender_num'] }, width: 10 },
        c2: { col: 'B', type: :string, style: :td, value: ->(r) { r['lot_num'] }, width: 5 },
        c3: { col: 'C', type: :string, style: :td, value: ->(r) { r['lot_name'].strip }, width: 35 },
        c4: { col: 'D', type: :float, style: :td_money, value: ->(r) { r['gkpz_cost'] }, sum: true, width: 15 },
        c5: { col: 'E', type: :float, style: :td_money, value: ->(r) { r['winner_cost'] }, sum: true, width: 15 },
        c6: {
          col: 'F', type: :string, style: :td_money,
          formula: ->(i) { %[=IF(E#{i},D#{i}-E#{i},"")] }, sum: true, sum_formula: true, width: 15
        },
        c7: {
          col: 'G', type: :string, style: :td_percent,
          formula: ->(i) { %[=IF(E#{i},(D#{i}-E#{i})/D#{i},"")] }, sum: true, sum_formula: true, width: 10
        },
        c8: {
          col: 'H', type: :float, style: :td_money, value: ->(r) { r['contract_cost'] }, sum: true, width: 15
        },
        c9: { col: 'I', type: :date, style: :td_date, value: ->(r) { r['wp_confirm_date'].try(:to_date) }, width: 12 },
        c10: { col: 'J', type: :string, style: :td, value: ->(r) { r['lot_status'] }, width: 15 },
        c11: { col: 'K', type: :string, style: :td, value: ->(r) { r['contract_num'] }, width: 15 },
        c12: { col: 'L', type: :date, style: :td_date, value: ->(r) { r['contract_date'].try(:to_date) }, width: 12 },
        c13: { col: 'M', type: :string, style: :td, value: ->(r) { r['winner'] }, width: 15 },
        c14: { col: 'N', type: :string, style: :td, value: ->(r) { r['gkpz_type'] }, width: 12 },
        c15: { col: 'O', type: :string, style: :td, value: ->(r) { r['fact_type'] }, width: 12 },
        c16: { col: 'P', type: :string, style: :td, value: ->(r) { r['tender_note'] }, width: 25 }
      }
    end
  end
end

module Reports
  module Gkpz
    class Checklist < Reports::Base
      attr_accessor :gkpz_state

      def groups
        @groups ||= YAML.load(ERB.new(File.read("#{structures}/gkpz.yml")).result(binding))
      end

      def default_params
        @default_params ||= {
          begin_date: date_begin.to_date,
          end_date: date_end.to_date,
          date_gkpz_on_state: date_gkpz_on_state.to_date,
          customer: customer.to_i,
          gkpz_year: gkpz_year.to_i
        }.with_indifferent_access
      end

      def result_rows(filter)
        checklist_sql_rows.select do |r|
          filter.all? { |k, v| Array(v).include?(r[k.to_s]) }
        end.sort_by { |r| r['sort_order'] }
      end

      COLUMNS = {
        c1: { type: :string, style: :td, value: ->(r) { r['specification_name'] }, width: 60 },
        c2: { type: :float, style: :td_money, value: ->(r) { r['cost'] }, sum: true, width: 25 },
        c3: { type: :float, style: :td_money, value: ->(r) { r['amount_mastery'] }, sum: true, width: 25 },
        c4: { type: :float, style: :td_money, value: ->(r) { r['contract_amount'] }, sum: true, width: 25 },
        c5: { type: :float, style: :td_money, value: ->(r) { (c3(r) || 0) + (c4(r) || 0) }, sum: true, width: 25 },
        c6: { type: :float, style: :td_money, value: ->(r) { r['bp_cost'] }, sum: true, width: 25 },
        c7: { type: :float, style: :td_money, value: ->(r) { r['pp_cost'] }, sum: true, width: 25 }
      }

      COLUMNS.each_pair do |ckey, cval|
        define_singleton_method(ckey) { |r| cval[:value].call(r) }
      end
    end
  end
end

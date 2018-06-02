module Reports
  module Gkpz
    class ExplanationSingleSource < Reports::Base
      attr_accessor :gkpz_state

      def groups
        @groups ||= YAML.load(ERB.new(File.read("#{structures}/gkpz.yml")).result(binding))
      end

      def default_params
        @default_params ||= {
          begin_date: date_begin.to_date,
          end_date: date_end.to_date,
          date_gkpz_on_state: date_gkpz_on_state.to_date,
          customer: customer.to_i
        }.with_indifferent_access
      end

      def result_rows(filter)
        explanation_single_source_sql_rows.select do |r|
          filter.all? { |k, v| Array(v).include?(r[k]) }
        end.sort_by { |r| r['sort_order'] }
      end

      COLUMNS = {
        c1: { type: :string, style: :td, width: 5 },
        c2: { type: :string, style: :td, value: ->(r) { r['bp_item'] }, width: 20 },
        c3: { type: :string, style: :td, value: ->(r) { r['specification_name'].strip }, width: 50 },
        c4: { type: :string, style: :td, value: ->(r) { r['tender_type_name'] }, width: 10 },
        c5: {
          type: :float, style: :td_money, value: ->(r) { r['cost_nds'] }, sum: true, width: 20
        },
        c6: { type: :string, style: :td, value: ->(r) { r['is_contr'] ? r['potential_bidder'] : r['potential_participants'] }, width: 25 },
        c7: {
          type: :string, style: :td, value: ->(r) { [r['tender_type_explanations'], r['note']].join('; ') }, width: 40
        },
        c8: { type: :string, style: :td, value: ->(r) { r['explanations_doc'] }, width: 25 },
        c9: { type: :string, style: :td, value: ->(r) { r['regulation_item_num'] }, width: 30 }
      }

      COLUMNS.each_pair do |ckey, cval|
        define_singleton_method(ckey) { |r| cval[:value].call(r) }
      end
    end
  end
end

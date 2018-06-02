module Reports
  module Other
    class EisTendersResult < Reports::Base

      def default_params
        @default_params ||= {
          date_begin: date_begin.to_date,
          date_end: date_end.to_date
        }.with_indifferent_access
      end

      def results(filter)
        send("#{Setting.company}_sql_rows").select do |r|
          filter.all? { |key, value| Array(value).include?(r[key.to_s]) }
        end
      end

      def total(filter)
        results(filter).inject do |h1, h2|
          h1.merge(h2) do |k, o, n|
            o + (n || 0) if %(lot_count, cost_nds).include?(k) # ? o + (n || 0) : o
          end
        end
      end

      FILTERS = [
        { name: "Все закупки" },
        { name: "Закупки у ЕИ", tender_type_id: Constants::TenderTypes::ONLY_SOURCE },
        { name: "Закупки с гостайной", privacy_id: Constants::StateSecrets::ALL },
        { name: "Закупки у СМП", is_sme: 1 }
      ]

      COLUMNS = {
        c1: { type: :string, style: :td, value: ->(r) { r['tender_num'] }, width: 20 },
        c2: { type: :string, style: :td, value: ->(r) { r['lot_name'] }, width: 50, sum_style: :sum_money },
        c3: { type: :string, style: :td_date, value: ->(r) { r['contract_date'].try(:to_date) }, width: 20, sum_style: :sum_money },
        c4: { type: :float, style: :td_money, value: ->(r) { r['cost_nds'] }, width: 20, sum_style: :sum_money },
      }
    end
  end
end

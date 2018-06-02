module Reports
  module Other
    class PurchaseFromSme < Reports::Base

      attr_accessor :detail, :order, :line, :row, :filter_rows

      def default_params
        @default_params ||= {
          customers: customers,
          end_date: date_end.to_date,
          begin_date: date_begin.to_date
        }.with_indifferent_access
      end

      def part1_row(filter)
        send("#{Setting.company}_part1_sql_rows").select do |r|
          filter.all? { |k, v| Array(v).include?(r[k.to_s]) }
        end.inject do |h1,h2|
          h1.merge(h2) do |k, o, n|
            %(cost_nds cost cnt cost_amount_nds cost_amount cnt_amount).include?(k) ? o + (n || 0) : o
          end
        end
      end

      def part2_row
        @part2_row ||= send("#{Setting.company}_part2_sql_rows").first
      end

      def part3_row
        @part3_row ||= send("#{Setting.company}_part3_sql_rows").first
      end

      def part4_row
        @part4_row ||= send("#{Setting.company}_part4_sql_rows").first
      end

      def part5_row
        @part5_row ||= send("#{Setting.company}_part5_sql_rows").first
      end

      def part6_row
        @part6_row ||= send("#{Setting.company}_part6_sql_rows").first
      end

      def part7_row
        @part7_row ||= send("#{Setting.company}_part7_sql_rows").first
      end

      def part8_row
        @part8_row ||= send("#{Setting.company}_part8_sql_rows").first
      end

      def detail_rows(filter = {})
        filter = {} unless line.to_i == 1
        self.send("#{Setting.company}_part#{line}_sql_rows").select do |r|
          filter.all? { |k, v| Array(v).include?(r[k.to_s]) }
        end
      end

      def customer_info
        @customer_info ||= Department.find(customers.first.to_i) if customers.present?
      end

      def year
        date_end.to_date.year
      end

      def address_info
        [
          customer_info.contact_postal_fias_name,
          customer_info.contact_phone,
          customer_info.contact_web
        ].compact.join('; ')
      end

      def self.row_title(suffix)
        I18n.t("#{to_s.underscore}.row_titles.#{suffix}")
      end

      def row_title(suffix, options = {})
        I18n.t("#{self.class.name.underscore}.row_titles.#{suffix}", options)
      end

      ROWS = {
        row1: { title: row_title('row1'), order1352: Order1352::ALL, num: 1 },
        row2: { title: row_title('row2'), order1352: nil, num: 2 },
        row3: { title: row_title('row3'), order1352: nil },
        row4: { title: row_title('row4'), order1352: nil },
        row5: { title: row_title('row5'), order1352: [41_003] },
        row6: { title: row_title('row6'), order1352: nil },
        row7: { title: row_title('row7'), order1352: [41_004] },
        row8: { title: row_title('row8'), order1352: [41_006] },
        row9: { title: row_title('row9'), order1352: [41_007] },
        row10: { title: row_title('row10'), order1352: [41_008] },
        row11: { title: row_title('row11'), order1352: [41_009] },
        row12: { title: row_title('row12'), order1352: [41_010] },
        row13: { title: row_title('row13'), order1352: [41_011] },
        row14: { title: row_title('row14'), order1352: [41_012] },
        row15: { title: row_title('row15'), order1352: [41_013] },
        row16: { title: row_title('row16'), order1352: [41_014] },
        row17: { title: row_title('row17'), order1352: nil },
        row18: { title: row_title('row18'), order1352: nil },
        row19: { title: row_title('row19'), order1352: [41_015] },
        row20: { title: row_title('row20'), order1352: nil },
        row21: { title: row_title('row21'), order1352: [41_016] },
        row22: { title: row_title('row22'), order1352: [41_017] },
        row23: { title: row_title('row23'), order1352: [41_018] },
        row24: { title: row_title('row24'), order1352: [41_019] },
        row25: { title: row_title('row25'), order1352: [41_020] },
        row26: { title: row_title('row26'), order1352: nil },
        row27: { title: row_title('row27'), order1352: nil },
        row28: { title: row_title('row28'), order1352: [41_021] },
        row29: { title: row_title('row29'), order1352: [41_022] }
      }

      COLUMNS_RAOESV = {
        c1: { type: :float, value: ->(r) { to_thousand(r['cost_nds']) }, style: :td_money, width: 25 },
        c2: { type: :float, value: ->(r) { to_thousand(r['cost']) }, style: :td_money, width: 25 },
        c3: { type: :integer, value: ->(r) { r['cnt'] }, style: :td, width: 10 },
        c4: { type: :float, value: ->(r) { to_thousand(r['cost_amount_nds']) }, style: :td_money, width: 25 },
        c5: { type: :float, value: ->(r) { to_thousand(r['cost_amount']) }, style: :td_money, width: 25 },
        c6: { type: :integer, value: ->(r) { r['cnt_amount'] }, style: :td, width: 10 }

      }

    end
  end
end

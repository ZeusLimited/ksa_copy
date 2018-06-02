module Reports
  module Other
    class InovationProductAmount < Reports::Base

      attr_accessor :detail, :line, :row, :target_place, :filter_rows

      def default_params
        @default_params ||= {
          begin_date: date_begin.to_date,
          end_date: date_end.to_date
        }.with_indifferent_access
      end

      def part1_row
        @part1_row ||= part1_sql_rows.first
      end

      def part2_row
        @part2_row ||= part2_sql_rows.first
      end

      def part3_row
        @part3_row ||= part3_sql_rows.first
      end

      def part4_row
        @part4_row ||= part4_sql_rows.first
      end

      def detail_rows
        results = send("part#{line}_sql_rows")
        case filter_rows
        when 'cnt'
          results.reject { |v|  v['is_current'].zero? }
        when 'cnt_amount'
          results.reject { |v|  v['is_ca'].zero? }
        else results
        end
      end

      def customer_info
        @customer_info ||= Department.find(customers.first.to_i) if customers.present?
      end

      def address_info
        [
          customer_info.contact_postal_fias_name,
          customer_info.contact_phone,
          customer_info.contact_web,
        ].compact.join('; ')
      end

      def year_begin
        date_begin.to_date.year
      end

      def year_end
        date_end.to_date.year
      end

      def self.row_title(suffix)
        I18n.t("#{to_s.underscore}.row_titles.#{suffix}")
      end

      def row_title(suffix, options = {})
        I18n.t("#{self.class.name.underscore}.row_titles.#{suffix}", options)
      end

      def purchase_increase(part1, part2, sme = nil)
        [nil, "_nds", '-', "_amount", "_amount_nds", '-'].map do |suffix|
          if suffix == '-'
            '-'
          elsif !part1["sum_contracts#{sme}#{suffix}"].to_f.zero?
            ((part2["sum_contracts#{sme}#{suffix}"].to_f - part1["sum_contracts#{sme}#{suffix}"].to_f) * 100 /
            part1["sum_contracts#{sme}#{suffix}"].to_f).round(2)
          end
        end
      end

      def purchase_share(part1, sme = nil)
        [nil, "_nds", '-', "_amount", "_amount_nds", '-'].map do |suffix|
          if suffix == '-'
            '-'
          elsif !part1["sum_contracts_all#{suffix}"].to_f.zero?
            (part1["sum_contracts#{sme.blank? ? '' : '_sme'}#{suffix}"].to_f /
            part1["sum_contracts_all#{suffix}"].to_f * 100).round(2)
          end
        end
      end
    end
  end
end

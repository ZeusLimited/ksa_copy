# frozen_string_literal: true

module Reports
  module Gkpz
    class GkpzOosCommon < Reports::Base
      attr_accessor :oos_etp

      def structure
        @structure ||= YAML.safe_load(ERB.new(File.read("#{structures}/gkpz_oos_common.yml")).result(binding))
      end

      def default_params
        @default_params ||= {
          for_order1352: false,
          begin_date: Date.new(gkpz_year.to_i, 1, 1),
          end_date: Date.new(gkpz_year.to_i, 12, 31),
          date_gkpz_on_state: date_gkpz_on_state.to_date,
          gkpz_year: gkpz_year.to_i,
        }.with_indifferent_access
      end

      # OOS_NEW
      def result(filters)
        rows_with_indifferent_access.select do |row|
          filters.all? { |k, v| Array(v).include?(row[k]) }
        end.sort_by { |r| r['ord'] }
      end

      def all_sum
        @all_sum ||= result({}).sum { |r| r['cost'] }
      end

      def for_order1352_sum
        @for_order1352_sum ||= result(order1352_id: Constants::Order1352::EXCLUSIONS + [nil]).sum { |r| r['cost'] }
      end

      def only_sme_sum
        @only_sme_sum ||= result(sme_type_id: Constants::SmeTypes::SME).sum { |r| r['cost'] }
      end

      def template
        if oos_etp.to_i == Constants::EtpAddress::NOT_ETP
          'reports/gkpz/gkpz_oos_common/gkpz_oos_new/main'
        else
          'reports/gkpz/gkpz_oos_common/plan_oos_etp/main'
        end
      end

      def etp_columns
        "Reports::Gkpz::GkpzOosCommon::COLUMNS_ETP_#{oos_etp}".constantize
      end

      # OOS_ETP
      def result_rows
        @result_rows ||= oos_sql_rows
      end

      COLUMNS_EIS = {
        c0: { type: :string, style: :td, value: ->(r) { r['rn'] }, width: 10 },
        c1: { type: :string, style: :td, value: ->(r) { r['okved'] }, width: 10 },
        c2: { type: :string, style: :td, value: ->(r) { r['okdp'] }, width: 10 },
        c3: { type: :string, style: :td, value: ->(r) { r['lot_name'] }, width: 40 },
        c4: { type: :string, style: :td, value: ->(r) { r['requirements'] }, width: 30 },
        c5: { type: :string, style: :td, value: ->(r) { r['unit_code'] }, width: 10 },
        c6: { type: :string, style: :td, value: ->(r) { r['unit_name'] }, width: 20 },
        c7: { type: :integer, style: :td, value: ->(r) { r['qty'] }, width: 10 },
        c8: { type: :string, style: :td, value: ->(r) { r['fias_okato'] }, width: 15 },
        c9: { type: :string, style: :td, value: ->(r) { r['fias_name'] }, width: 20 },
        c10: { type: :float, style: :td_money, value: ->(r) { r['cost'] }, width: 20, sum: true },
        c11: { type: :float, style: :td_money, value: ->(r) { r['cost_nds'] }, width: 20, sum: true },
        c12: { type: :date, style: :td_date, value: ->(r) { r['announce_date'].try(:to_date) }, width: 15 },
        c13: { type: :date, style: :td_date, value: ->(r) { r['delivery_date_end'].try(:to_date) }, width: 15 },
        c14: { type: :string, style: :td, value: ->(r) { r['tender_type_name'] }, width: 15 },
        c15: { type: :string, style: :td, value: ->(r) { r['is_elform'] }, width: 15 },
      }.freeze

      COLUMNS_ETP_12002 = {
        c0: { type: :string, style: :td, value: ->(r) { r['rn'] }, width: 10 },
        c1: { type: :string, style: :td, value: ->(r) { r['okved'] }, width: 15 },
        c2: { type: :string, style: :td, value: ->(r) { r['okdp'] }, width: 15 },
        c3: { type: :string, style: :td, value: ->(r) { r['lot_name'] }, width: 30 },
        c4: { type: :string, style: :td, value: ->(r) { r['requirements'] }, width: 20 },
        c5: { type: :string, style: :td, value: ->(r) { r['unit_code'] }, width: 10 },
        c6: { type: :string, style: :td, value: ->(r) { r['unit_name'] }, width: 20 },
        c7: { type: :integer, style: :td, value: ->(r) { r['qty'] }, width: 10 },
        c8: { type: :string, style: :td, value: ->(r) { r['fias_okato'] }, width: 15 },
        c9: { type: :string, style: :td, value: ->(r) { r['fias_name'] }, width: 20 },
        c10: { type: :float, style: :td_money, value: ->(r) { r['cost'] }, width: 15 },
        c11: { type: :date, style: :td_date, value: ->(r) { r['announce_date'].try(:to_date) }, width: 15 },
        c12: { type: :date, style: :td_date, value: ->(r) { r['delivery_date_end'].try(:to_date) }, width: 15 },
        c13: { type: :string, style: :td, value: ->(r) { r['tender_type_name'] }, width: 15 },
        c14: { type: :string, style: :td, value: ->(r) { r['is_elform'] }, width: 15 },
        c15: { type: :string, style: :td, value: ->(r) { r['oos_tender_type_code'] }, width: 10 },
        c16: { type: :string, style: :td, value: ->(r) { r['consumer_name'] }, width: 15 },
        c17: { type: :string, style: :td, value: ->(r) { r['sme'] }, width: 15 },
        c18: { type: :string, style: :td, value: ->(r) { r['order1352'] }, width: 20 },
        c19: { type: :integer, style: :td, value: ->(r) { r['empty'] }, width: 20 },
        c20: { type: :string, style: :td, value: ->(r) { r['empty'] }, width: 20 },
        c21: { type: :string, style: :td, value: ->(r) { r['empty'] }, width: 20 },
        c22: { type: :string, style: :td, value: ->(r) { r['innovation'] }, width: 20 },
        c23: { type: :string, style: :td, value: ->(r) { r['empty'] }, width: 20 },
        c24: { type: :string, style: :td, value: ->(r) { r['empty'] }, width: 20 },
        c25: { type: :string, style: :td, value: ->(r) { r['empty'] }, width: 20 },
        c26: { type: :string, style: :td, value: ->(r) { r['empty'] }, width: 20 },
      }.freeze

      def self.generalize_okato(okato)
        (2..10).each { |i| okato[i] = '0' }
        okato
      end

      def self.change_reason(row)
        lot_change(row) + cost_difference(row)
      end

      def self.lot_change(args)
        return 1 if
          args['first_announce_date'] != args['second_announce_date'] ||
          args['first_tender_type'] != args['second_tender_type'] ||
          args['first_delivery_date'] != args['second_delivery_date'] ||
          args['gkpz_first_state']&.zero?
        0
      end

      def self.cost_difference(args)
        return 2 if
          args['gkpz_first_cost'].to_f * 1.1 < args['gkpz_last_cost'].to_f
        0
      end

      def self.eetp_status(row)
        return row['status'] if change_reason(row).zero? || row['status'] == 'A'
        'C'
      end

      COLUMNS_ETP_12004 = {
        c0: { type: :string, style: :td_text, value: ->(r) { r['rn'] }, width: 10 },
        c1: { type: :string, style: :td_text, value: ->(r) { r['okved'] }, width: 15 },
        c2: { type: :string, style: :td_text, value: ->(r) { r['okdp'] }, width: 15 },
        c3: { type: :string, style: :td_text, value: ->(r) { r['lot_name'] }, width: 30 },
        c4: { type: :string, style: :td_text, value: ->(r) { r['requirements'] }, width: 20 },
        c5: { type: :string, style: :td_text, value: ->(r) { r['unit_code'] }, width: 10 },
        c6: { type: :string, style: :td_text, value: ->(r) { r['unit_name'] }, width: 20 },
        c7: { type: :string, style: :td_text, value: ->(r) { r['qty'] }, width: 10 },
        c8: { type: :string, style: :td_text, value: ->(r) { generalize_okato(r['fias_okato']) }, width: 15 },
        c9: { type: :string, style: :td_text, value: ->(r) { r['fias_name'] }, width: 20 },
        c10: { type: :string, style: :td_text, value: ->(r) { r['cost'] }, width: 15 },
        c11: { type: :string, style: :td_text, value: ->(r) { r['announce_date'].try(:to_date) }, width: 15 },
        c12: { type: :string, style: :td_text, value: ->(r) { r['delivery_date_end'].try(:to_date) }, width: 15 },
        c13: { type: :string, style: :td_text, value: ->(r) { r['tender_type_fullname'] }, width: 15 },
        c14: { type: :string, style: :td_text, value: ->(r) { r['is_elform_roseltorg'] }, width: 15 },
        c15: { type: :string, style: :td_text, value: ->(r) { r['oos_tender_type_code_roseltorg'] }, width: 10 },
        c16: { type: :string, style: :td_text, value: ->(_) { 'RUB' }, width: 15 },
        c17: { type: :string, style: :td_text, value: ->(r) { r['sme_roseltorg'] }, width: 15 },
        c18: { type: :string, style: :td_text, value: ->(r) { r['order1352_roseltorg'] }, width: 20 },
        c19: { type: :string, style: :td_text, value: ->(r) { r['exchange_rate'] }, width: 20 },
        c20: { type: :string, style: :td_text, value: ->(r) { r['date_exchange_rate'] }, width: 20 },
        c21: { type: :string, style: :td_text, value: ->(r) { r['cost'] }, width: 15 },
        c22: { type: :string, style: :td_text, value: ->(r) { r['innovation_roseltorg'] }, width: 20 },
        c23: { type: :string, style: :td_text, value: ->(r) { change_reason(r) }, width: 20 },
        c24: { type: :string, style: :td_text, value: ->(r) { r['additional_info'] }, width: 20 },
        c25: { type: :string, style: :td_text, value: ->(r) { eetp_status(r) }, width: 20 },
        c26: { type: :string, style: :td_text, value: ->(r) { r['cancellation_reason'] }, width: 20 },
        c27: { type: :string, style: :td_text, value: ->(r) { r['is_long_term'] }, width: 15 },
        c28: { type: :string, style: :td_text, value: ->(r) { r['amount_long_term'] }, width: 20 },
        c29: { type: :string, style: :td_text, value: ->(r) { r['amount_long_term_sme'] }, width: 20 },
      }.freeze

      private

      def rows_with_indifferent_access
        @rows_with_indifferent_access ||= oos_sql_rows.map(&:with_indifferent_access)
      end
    end
  end
end

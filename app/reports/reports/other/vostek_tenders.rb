module Reports
  module Other
    class VostekTenders < Reports::Base
      attr_accessor :users

      def default_params
        @default_params ||= {
          start_date: Date.new(2015, 07, 01),
          begin_date: date_begin.to_date,
          end_date: date_end.to_date
        }.with_indifferent_access
      end

      def l(key, attribute)
        I18n.t([model_name.i18n_key, "table", key, attribute].join('.'))
      end

      ROWS = {
        row_1: { sql: 'public_count + review_winner_count + open_count', parent: true },
        row_1_1: { sql: 'public_count' },
        row_1_2: { sql: 'public_count' },
        row_1_3: { sql: 'public_count' },
        row_1_4: { sql: 'review_winner_count' },
        row_1_5: { sql: 'open_count' },
        row_2: { sql: 'public_count + etp_public_count + oos_public_count', parent: true },
        row_2_1: { sql: 'etp_public_count' },
        row_2_2: { sql: 'oos_public_count' },
        row_2_3: { sql: 'public_count' },
        row_2_4: { sql: 'public_count' },
        row_2_5: { sql: 'public_count' },
        row_3: { sql: 'requests_count', parent: true },
        row_3_1: { sql: 'requests_count' },
        row_3_2: { sql: 'requests_count' },
        row_4: { sql: 'files_count', parent: true },
        row_4_1: { sql: 'files_count' },
        row_4_2: { sql: 'files_count' },
        row_4_3: { sql: 'files_count' },
        row_4_4: { sql: 'files_count' },
        row_5: { sql: 'open_count', parent: true },
        row_5_1: { sql: 'open_count' },
        row_5_2: { sql: 'open_count' },
        row_5_3: { sql: 'open_count' },
        row_5_4: { sql: 'open_count' },
        row_6: { sql: 'review_count', parent: true },
        row_6_1: { sql: 'review_count' },
        row_6_2: { sql: 'review_count' },
        row_6_3: { sql: 'review_count' },
        row_6_4: { sql: 'review_count' },
        row_7: { sql: 'rebid_count', parent: true },
        row_7_1: { sql: 'rebid_count' },
        row_7_2: { sql: 'rebid_count' },
        row_7_3: { sql: 'rebid_count' },
        row_7_4: { sql: 'rebid_count' },
        row_8: { sql: 'winner_count', parent: true },
        row_8_1: { sql: 'winner_count' },
        row_8_2: { sql: 'winner_count' },
        row_8_3: { sql: 'winner_count' },
        row_8_4: { sql: 'winner_count' },
        row_9: { sql: 'result_count', parent: true },
        row_9_1: { sql: 'result_count' },
        row_9_2: { sql: 'result_count' },
        row_9_3: { sql: 'result_count' },
        row_9_4: { sql: 'result_count' },
        row_10: { sql: 'contract_count', parent: true },
        row_10_1: { sql: 'contract_count' }
      }

      PIVOT_ROWS = {
        all_row_1: 'all_public_count + all_review_winner_count + all_open_count',
        all_row_1_1: 'all_public_count',
        all_row_1_2: 'all_public_count',
        all_row_1_3: 'all_public_count',
        all_row_1_4: 'all_review_winner_count',
        all_row_1_5: 'all_open_count',
        all_row_2: 'all_public_count + all_etp_public_count + all_oos_public_count',
        all_row_2_1: 'all_etp_public_count',
        all_row_2_2: 'all_oos_public_count',
        all_row_2_3: 'all_public_count',
        all_row_2_4: 'all_public_count',
        all_row_2_5: 'all_public_count',
        all_row_3: 'all_requests_count',
        all_row_3_1: 'all_requests_count',
        all_row_3_2: 'all_requests_count',
        all_row_4: 'all_files_count',
        all_row_4_1: 'all_files_count',
        all_row_4_2: 'all_files_count',
        all_row_4_3: 'all_files_count',
        all_row_4_4: 'all_files_count',
        all_row_5: 'all_open_count',
        all_row_5_1: 'all_open_count',
        all_row_5_2: 'all_open_count',
        all_row_5_3: 'all_open_count',
        all_row_5_4: 'all_open_count',
        all_row_6: 'all_review_count',
        all_row_6_1: 'all_review_count',
        all_row_6_2: 'all_review_count',
        all_row_6_3: 'all_review_count',
        all_row_6_4: 'all_review_count',
        all_row_7: 'all_rebid_count',
        all_row_7_1: 'all_rebid_count',
        all_row_7_2: 'all_rebid_count',
        all_row_7_3: 'all_rebid_count',
        all_row_7_4: 'all_rebid_count',
        all_row_8: 'all_winner_count',
        all_row_8_1: 'all_winner_count',
        all_row_8_2: 'all_winner_count',
        all_row_8_3: 'all_winner_count',
        all_row_8_4: 'all_winner_count',
        all_row_9: 'all_result_count',
        all_row_9_1: 'all_result_count',
        all_row_9_2: 'all_result_count',
        all_row_9_3: 'all_result_count',
        all_row_9_4: 'all_result_count',
        all_row_10: 'all_contract_count',
        all_row_10_1: 'all_contract_count'
      }
    end
  end
end

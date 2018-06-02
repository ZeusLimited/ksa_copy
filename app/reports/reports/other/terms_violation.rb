# frozen_string_literal: true

module Reports
  module Other
    class TermsViolation < Reports::Base
      attr_accessor :consumers

      def default_params
        @default_params ||= {
          begin_date: date_begin.to_date,
          end_date: date_end.to_date,
          gkpz_years: gkpz_years ? gkpz_years.map(&:to_i) : nil
        }.with_indifferent_access
      end

      def group_by_organizers
        violation_sql_rows.group_by do |row|
          row['organizer_name']
        end.sort
      end

      def group_violation_rows
        result_set = group_by_organizers.map.with_index(1) do |(organizer_name, rows), rn|
          reduce_rows(rows, rn, organizer_name)
        end

        result_set << reduce_rows(result_set, result_set.last['rn'] + 1, 'Итого') unless result_set.empty?
        result_set
      end

      def reduce_rows(rows, rn, org_name)
        result = rows.reduce(row_init_hash) do |memo, row|
          memo['cnt'] += (row['not_publish_cnt'] + row['publish_cnt'])
          memo['publish_cnt'] += row['publish_cnt']
          memo['not_publish_cnt'] += row['not_publish_cnt']
          memo['violation_days'] += TermsViolation.violation_working_days_between(row)
          memo
        end
        result['rn'] = rn
        result['organizer_name'] = org_name
        result['avg_violation_day'] = result['violation_days'] / result['cnt']
        result
      end

      def self.violation_working_days_between(row)
        return row['violation_days'] unless row['date_from'] && row['date_to']
        violation_date_from = 30.business_days.after(row['date_from'])
        violation_date_from.business_days_until(row['date_to'])
      end

      COLUMNS = {
        c0: { type: :integer, style: :td, value: ->(r) { r['rn'] }, width: 10, sum_style: :sum },
        c1: { type: :string, style: :td, value: ->(r) { r['lot_num'] }, width: 10, sum_style: :sum },
        c2: {
          type: :string, style: :td, no_merge: true, value: ->(r) { r['consumer_name'] }, width: 20, sum_style: :sum
        },
        c3: { type: :string, style: :td, value: ->(r) { r['organizer_name'] }, width: 20, sum_style: :sum },
        c4: { type: :string, style: :td, value: ->(r) { r['lot_name'] }, width: 40, sum_style: :sum },
        c5: {
          type: :string, style: :td, sum_title: 'Итого:',
          value: ->(r) { r['tender_type_name'] }, width: 15, sum_style: :sum
        },
        c6: {
          type: :float, alt_type: :string, style: :td_money, no_merge: true,
          formula: ->(i, ii) { "=SUM(G#{i}:G#{ii})" }, value: ->(r) { r['cost'] },
          width: 20, sum_style: :sum
        },
        c7: { type: :float, style: :td_money, no_merge: true, value: ->(r) { r['nmcd'] }, width: 20, sum_style: :sum },
        c8: {
          type: :string, style: :td, no_merge: true, value: ->(r) { r['direction_name'] }, width: 15, sum_style: :sum
        },
        c9: { type: :string, style: :td_date, value: ->(r) { r['plan_announce'] }, width: 15, sum_style: :sum },
        c10: { type: :string, style: :td_date, value: ->(r) { r['fact_announce'] }, width: 15, sum_style: :sum },
        c11: { type: :string, style: :td_date, value: ->(r) { r['summary_plan'] }, width: 15, sum_style: :sum },
        c12: {
          type: :string, style: :td_date, sum_title: 'Итого:',
          value: ->(r) { r['summary_fact'] }, width: 15, sum_style: :sum
        },
        c13: {
          type: :integer, alt_type: :string, style: :td, formula: ->(i, ii) { "=SUM(N#{i}:N#{ii})" },
          value: ->(r) { violation_working_days_between(r) }, width: 15, sum_style: :sum
        },
        c14: { type: :string, style: :td, value: ->(r) { r['violation_reason'] }, width: 30, sum_style: :sum },
      }

      GROUP_COLUMNS = {
        c0: { type: :integer, style: :td, value: ->(r) { r['rn'] }, width: 10 },
        c1: { type: :string, style: :td, value: ->(r) { r['organizer_name'] }, width: 35 },
        c2: { type: :integer, style: :td, value: ->(r) { r['cnt'] }, width: 35 },
        c3: { type: :integer, style: :td, value: ->(r) { r['publish_cnt'] }, width: 35 },
        c4: { type: :integer, style: :td, value: ->(r) { r['not_publish_cnt'] }, width: 35 },
        c5: { type: :integer, style: :td, value: ->(r) { r['violation_days'] }, width: 35 },
        c6: { type: :integer, style: :td, value: ->(r) { r['avg_violation_day'] }, width: 35 },
      }

      private

      def row_init_hash
        {
          'cnt' => 0,
          'publish_cnt' => 0,
          'not_publish_cnt' => 0,
          'violation_days' => 0
        }
      end

    end
  end
end

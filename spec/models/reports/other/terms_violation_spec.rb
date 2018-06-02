require 'spec_helper'

RSpec.describe Reports::Other::TermsViolation, type: :model do
  let(:options) do
    {
      date_begin: Date.new(Time.current.year, 1, 1),
      date_end: Date.new(Time.current.year, 12, 31),
      gkpz_years: [Time.current.year]
    }
  end

  let(:terms_violation) { Reports::Other::TermsViolation.new(options) }

  describe '#default_params' do
    it 'return correct default_params' do
      expected_result = {
        begin_date: Date.new(Time.current.year, 1, 1).to_date,
        end_date: Date.new(Time.current.year, 12, 31).to_date,
        gkpz_years: [Time.current.year]
      }.with_indifferent_access
      expect(terms_violation.default_params).to eq(expected_result)
    end
  end

  describe '.violation_working_days_between' do
    let(:row) { { 'date_from' => date_from, 'date_to' => date_to, 'violation_days' => violation_days } }
    let(:violation_days) { Faker::Number.number(2) }
    context 'when dates present' do
      let(:date_to) { Faker::Date.between(30.business_days.ago, 10.business_days.ago) }
      let(:date_from) { date_to - 60 }
      it 'return violation working days' do
        violation_date_from = 30.business_days.after(date_from)
        expect(Reports::Other::TermsViolation.violation_working_days_between(row)).to eq(violation_date_from.business_days_until(date_to))
      end
    end

    context 'when dates not present' do
      let(:date_to) { nil }
      let(:date_from) { nil }
      it 'return calculated days' do
        expect(Reports::Other::TermsViolation.violation_working_days_between(row)).to eq(violation_days)
      end
    end
  end

  describe '#reduce_rows' do
    let(:rows) do
      [
        {
          'publish_cnt' => 4,
          'not_publish_cnt' => 4,
          'violation_days' => 6
        },
        {
          'publish_cnt' => 2,
          'not_publish_cnt' => 2,
          'violation_days' => 6
         }
      ]
    end

    it 'return reduced rows' do
      expect(terms_violation.reduce_rows(rows, 1, 'Test')).to \
        eq(
          {
            'rn' => 1,
            'organizer_name' => 'Test',
            'cnt' => 12,
            'publish_cnt' => 6,
            'not_publish_cnt' => 6,
            'violation_days' => 12,
            'avg_violation_day' => 1
          }
        )
    end
  end
end

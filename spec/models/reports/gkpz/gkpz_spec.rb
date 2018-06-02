require 'spec_helper'

RSpec.describe Reports::Gkpz::Gkpz do
  let(:options) do
    {
      date_begin: Date.new(Time.now.year - 1, 1, 1),
      date_end: Date.new(Time.now.year, 12, 31),
      date_gkpz_on_state: Date.new(Time.now.year, 12, 31),
      gkpz_years: [Time.now.year]
    }
  end

  let(:gkpz) { Reports::Gkpz::Gkpz.new(options) }

  describe '#default_params' do
    it 'return correct default_params' do
      expected_result = {
        begin_date: Date.new(Time.now.year - 1, 1, 1),
        end_date: Date.new(Time.now.year, 12, 31),
        date_gkpz_on_state: Date.new(Time.now.year, 12, 31)
      }.with_indifferent_access
      expect(gkpz.default_params).to eq(expected_result)
    end
  end

  context 'rows filters' do
    let(:rows) do
      [
        { a: 5, sort_order: 2, root_customer_name: 'a' },
        { a: 4, sort_order: 1, root_customer_name: 'b' }
      ].map { |h| h.with_indifferent_access }
    end

    before(:example) do
      allow(gkpz).to receive(:rows_with_indifferent_access).and_return rows
    end

    describe '#filter_rows' do
      it 'filter passed rows by passed filter params' do
        expect(gkpz.filter_rows(rows, a: 5)).to eq([{ 'a' => 5, 'sort_order' => 2, 'root_customer_name' => 'a' }])
      end
    end

    describe '#result_rows_by_customers' do
      it 'divide filtred rows by root_customer_name' do
        expect(gkpz.result_rows_by_customers).to \
          eq({
              'a' => [{ 'a' => 5, 'sort_order' => 2, 'root_customer_name' => 'a' }],
              'b' => [{ 'a' => 4, 'sort_order' => 1, 'root_customer_name' => 'b' }]
            })
      end
    end

    describe '#result_rows' do
      it 'sort filtred rows by sort_order' do
        allow(gkpz).to receive(:filter_rows).and_return(rows)
        expect(gkpz.result_rows({})).to \
          eq([
              { 'a' => 4, 'sort_order' => 1, 'root_customer_name' => 'b' },
              { 'a' => 5, 'sort_order' => 2, 'root_customer_name' => 'a' }
            ])
      end
    end
  end
end

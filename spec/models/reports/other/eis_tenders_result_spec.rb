require 'spec_helper'

describe Reports::Other::EisTendersResult do
  let(:options) do
    {
      date_begin: Date.new(Time.current.year, 1, 1),
      date_end: Date.new(Time.current.year, 12, 31)
    }
  end

  let(:eis_tenders_result) { Reports::Other::EisTendersResult.new(options) }

  describe '#default_params' do
    it 'return correct default_params' do
      expected_result = {
        date_begin: Date.new(Time.current.year, 1, 1).to_date,
        date_end: Date.new(Time.current.year, 12, 31).to_date
      }.with_indifferent_access
      expect(eis_tenders_result.default_params).to eq(expected_result)
    end
  end

end


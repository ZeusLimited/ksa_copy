require 'spec_helper'

RSpec.describe Reports::Other::StartForm, type: :model do
  let(:options) do
    {
      date_begin: Date.new(Time.current.year, 1, 1),
      date_end: Date.new(Time.current.year, 12, 31),
      gkpz_year: [Time.current.year]
    }
  end

  let(:start_form) { Reports::Other::StartForm.new(options) }

  describe '#default_params' do
    it 'return correct default_params' do
      expected_result = {
        begin_date: Date.new(Time.current.year, 1, 1).to_date,
        end_date: Date.new(Time.current.year, 12, 31).to_date,
        gkpz_year: [Time.current.year],
        start_date: Date.new(Time.current.year, 1, 1).to_date
      }.with_indifferent_access
      expect(start_form.default_params).to eq(expected_result)
    end
  end

  describe '#merge_rows' do
    it 'return merged hash' do
      hash_array = [
        { 'first' => 'first', 'plan_count' => 5 },
        { 'first' => 'first', 'plan_count' => 5 }
      ]
      final_hash = { 'first' => 'first', 'plan_count' => 10 }
      expect(start_form.merge_rows(hash_array)).to eq(final_hash)
    end
  end

  describe '#united_columns' do
    let(:not_united_array) do
      [
        [
          { 'department_id' => 2, 'direction_id' => 1, 'plan_count' => 100 },
          { 'department_id' => 2, 'direction_id' => 2,  'plan_count' => 100 },
          { 'department_id' => 2, 'direction_id' => 3,  'plan_count' => 100 }
        ],
        [
          { 'department_id' => 2, 'direction_id' => 1, 'plan_cost' => 100 },
          { 'department_id' => 2, 'direction_id' => 2,  'plan_cost' => 100 },
          { 'department_id' => 2, 'direction_id' => 3,  'plan_cost' => 100 }
        ],
        [
          { 'department_id' => 2, 'direction_id' => 1, 'all_plan_count' => 100 },
          { 'department_id' => 2, 'direction_id' => 2,  'all_plan_count' => 100 },
          { 'department_id' => 2, 'direction_id' => 3,  'all_plan_count' => 100 }
        ]
      ]
    end
    it 'return united columns' do
      result_hash = { 'department_id' => 2, 'direction_id' => 1, 'plan_count' => 300, 'plan_cost' => 300, 'all_plan_count' => 300 }
      expect(start_form.united_columns(not_united_array)).to eq(result_hash)
    end
  end

  describe '#part1_rows' do
    it 'call bunch of methods' do
      fake_result = instance_double(ActiveRecord::Result)

      expect(start_form).to receive(:part_1_1_sql_rows).and_return(fake_result)
      expect(start_form).to receive(:part_1_2_1_sql_rows).and_return(fake_result)
      expect(start_form).to receive(:part_1_2_2_sql_rows).and_return(fake_result)
      expect(start_form).to receive(:part_1_2_3_sql_rows).and_return(fake_result)
      expect(start_form).to receive(:part_1_2_4_sql_rows).and_return(fake_result)

      expect(fake_result).to receive(:select)
      expect(fake_result).to receive(:select)
      expect(fake_result).to receive(:select)
      expect(fake_result).to receive(:select)
      expect(fake_result).to receive(:select)

      expect(start_form).to receive(:united_columns).with(Array)

      start_form.part1_rows(test: 1)
    end
  end
end

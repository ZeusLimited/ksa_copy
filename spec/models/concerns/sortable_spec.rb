require 'spec_helper'

describe Sortable do
  before(:all) do
    class TestClass
      include ActiveModel::Model
      include Sortable
    end
  end

  let(:test_obj) { TestClass.new(sort_column: 'num', sort_direction: 'asc') }

  describe '#sort_direction' do
    context 'when @sort_direction nil' do
      it 'return asc' do
        test_obj.sort_direction = nil
        expect(test_obj.send(:sort_direction)).to eq('asc')
      end
    end

    context 'when @sort_direction not nil' do
      it 'return @sort_direction' do
        expect(test_obj.send(:sort_direction)).to eq('asc')
      end
    end
  end

  describe '#sort_direction_desc?' do
    context 'when sort direction eq desc' do
      it 'return true' do
        test_obj.sort_direction = 'desc'
        expect(test_obj.send(:sort_direction_desc?)).to eq(true)
      end
    end

    context 'when sort direction asc' do
      it 'return false' do
        expect(test_obj.send(:sort_direction_desc?)).to eq(false)
      end
    end
  end

  describe '#sort_column' do
    context 'when @sort_column nil' do
      it 'return id' do
        test_obj.sort_column = nil
        expect(test_obj.send(:sort_column)).to eq('id')
      end
    end

    context 'whent @sort_column not nil' do
      it 'return @sort_column' do
        expect(test_obj.send(:sort_column)).to eq('num')
      end
    end
  end

  describe '#max_sort_column' do
    let(:array_of_objects) { [build(:order, num: '10'), build(:order, num: '20')] }
    it 'return max value from array of objects' do
      test_obj.sort_column = 'num'
      expect(test_obj.send(:max_sort_column, array_of_objects)).to eq('20')
    end
  end
end

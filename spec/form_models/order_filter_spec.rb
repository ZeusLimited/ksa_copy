require 'spec_helper'

describe OrderFilter do
  describe '#search' do
    context 'when there is no args' do
      let(:order_filter) { OrderFilter.new }
      it "call a bunch of methods" do
        expect(Order).to receive_message_chain(:includes, :references, :where, :where, :sort_by)
        order_filter.search
      end
    end

    context 'when there is num' do
      let(:order_filter) { OrderFilter.new(num: '1234') }
      it "call a bunch of methods" do
        expect(Order).to receive_message_chain(:includes, :references, :where, :where, :where, :sort_by)
        order_filter.search
      end
    end

    context 'when there are present num, customers' do
      let(:order_filter) { OrderFilter.new(num: '1234', customers: ['123', '321']) }
      it "call a bunch of methods" do
        expect(Order).to receive_message_chain(:includes, :references, :where, :where, :where, :where, :sort_by)
        order_filter.search
      end
    end

    context 'when there are present num, customers and not_confirmed' do
      let(:order_filter) { OrderFilter.new(num: '1234', customers: ['123', '321'], not_confirmed: true) }
      it "call a bunch of methods" do
        expect(Order).to receive_message_chain(:includes, :references, :where, :where, :where, :where, :where, :sort_by)
        order_filter.search
      end
    end

    context 'when there is sort_direction_desc? = true' do
      let(:order_filter) { OrderFilter.new }
      it "call a bunch of methods" do
        allow(order_filter).to receive(:sort_direction_desc?).and_return(true)
        expect(Order).to receive_message_chain(:includes, :references, :where, :where, :sort_by, :reverse)
        order_filter.search
      end
    end


  end
end

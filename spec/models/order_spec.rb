require 'spec_helper'

RSpec.describe Order, type: :model do
  let(:order_approved) { create(:order, :approved) }
  let(:order_not_approved) { create(:order, agreed_by_user_id: nil) }

  let(:valid_attrs) { attributes_for(:order) }
  let(:invalid_attrs) { attributes_for(:order).merge(num: nil) }

  describe '#confirmed?' do
    it 'return true if order confirmed' do
      expect(order_approved.confirmed?).to eq(true)
    end
    it 'return false if order not confirmed' do
      expect(order_not_approved.confirmed?).to eq(false)
    end
  end

  describe '#save_with_plan_lots' do
    let(:plan_lot) { create(:plan_lot) }

    it 'return true if all lots saved to order' do
      user = instance_double(User)
      allow(user).to receive(:plan_lots).and_return [plan_lot]
      order = build(:order, valid_attrs)
      expect(order.save_with_plan_lots(user)).to eq true
    end
    it 'return false if it cant save orders' do
      user = instance_double(User)
      allow(user).to receive(:plan_lots).and_return [plan_lot]
      order = build(:order, invalid_attrs)
      expect(order.save_with_plan_lots(user)).to eq false
    end
  end

  describe '#root_customer_names' do
    let(:plan_lot) { create(:plan_lot_with_order) }
    it 'return only one customer name' do
      order = plan_lot.orders.last
      expect(order.root_customer_names).to eq(plan_lot.root_customer.name)
    end
  end

  describe '#set_agreed_by' do
    let(:user) { build(:user_user) }
    let(:order) { build(:order, :without_users) }

    it 'set agreed_by user' do
      order.agreed_by = user
      order.send :set_agreed_by
      expect(order.agreed_by).to eq(user)
    end

    context 'when there is no agreement date' do
      it "it set agreed_by user to nil" do
        order.agreed_by = user
        order.agreement_date = nil
        order.send :set_agreed_by
        expect(order.agreed_by).to eq(nil)
      end
    end
  end

  describe '#set_params' do
    let(:user) { build(:user_user) }
    let(:order) { build(:order) }
    before(:example) do
      order.set_params(user)
    end

    it 'assigns received_from_user_id' do
      expect(order.received_from_user_id).to eq(user.id)
    end

    it 'assigns agreed_by_user_id ' do
      expect(order.agreed_by_user_id).to eq(user.id)
    end

    it 'assigns plan_lots' do
      expect(order.plan_lots).to eq(user.plan_lots)
    end
  end
end

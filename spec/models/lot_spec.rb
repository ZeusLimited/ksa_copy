require 'spec_helper'
include Constants

describe Lot do
  it "#fullname" do
    expect(
      create(:lot_with_spec, num: 1, sublot_num: 1, name: "наименование").fullname
    ).to eq("Лот №1. Подлот №1.: наименование")
  end

  describe "#customers" do
    it "uniq customers from specs" do
      lot = build(:lot, specifications: [build(:specification, customer: build(:department, name: "AAA")),
                                         build(:specification, customer: build(:department, name: "BBB")),
                                         build(:specification, customer: build(:department, name: "AAA"))])
      expect(lot.customers).to eq(["AAA", "BBB"])
    end
  end

  it "#specs_cost" do
    lot = build(:lot, specifications: [build(:specification, qty: nil, cost: 200.00, cost_nds: 200.00),
                                       build(:specification, qty: 10, cost: 4000.00, cost_nds: 4000.00)])
    expect(lot.specs_cost).to eq(40_000.0)
  end

  describe "#any_existing_contract?" do
    let(:lot_with_contract) { create(:lot_with_contract) }
    let(:lot_with_contract_termination) { create(:lot_with_contract_termination) }
    let(:lot) { create(:lot) }
    it "returns true" do
      expect(lot_with_contract.any_existing_contract?).to eq(true)
    end
    it "returns false" do
      expect(lot_with_contract_termination.any_existing_contract?).to eq(false)
    end
    it "returns false" do
      expect(lot.any_existing_contract?).to eq(false)
    end
  end

  describe "#can_copy?" do
    let(:tender_fail) { create(:tender_with_fail_lot) }
    let(:tender_winner) { create(:tender_with_winner_lot) }
    let(:tender_contract) { create(:tender_with_contract_lot) }

    it "returns true" do
      expect(tender_fail.lots[0].can_copy?).to eq(true)
    end

    it "returns false" do
      expect(tender_winner.lots[0].can_copy?).to eq(false)
    end

    it "returns false" do
      expect(tender_contract.lots[0].can_copy?).to eq(false)
    end
  end

  describe '#set_order' do
    let(:lot) { create(:lot_with_spec, :with_plan_lot_with_order) }
    it 'set valid order from the plan to the lot' do
      lot.send :set_order
      expect(lot.order).to eq(lot.plan_lot.last_valid_order)
    end
  end

  describe '#winner_cost' do
    let!(:lot) { create(:lot, specifications: [build(:specification, qty: 10)]) }
    before(:each) do
      create(:offer,
             :win,
             lot: lot,
             offer_specifications: [build(:offer_specification,
                                          specification_id: lot.specifications[0].id,
                                          final_cost: 500)])
    end

    it "qty * final_cost" do
      expect(lot.winner_cost).to eq(5000)
    end
  end

  describe "#winner_single_source?" do
    it "true" do
      lot = build(:lot, winner_protocol_lots: [build(:winner_protocol_lot, :single_source)])
      expect(lot.winner_single_source?).to be_truthy
    end

    context "false" do
      it "winner_protocol_lots are blank" do
        lot = build(:lot)
        expect(lot.winner_single_source?).to be_falsey
      end
      it "the last lot from winner_protocol_lots does not contain the single_source solution" do
        lot = build(:lot, winner_protocol_lots: [build(:winner_protocol_lot, :single_source),
                                                 build(:winner_protocol_lot, :winner)])
        expect(lot.winner_single_source?).to be_falsey
      end
    end
  end

  describe '#valid_num_plan_eis' do
    it 'not to return error_message if length num_plan_eis less 20' do
      lot = build(:lot, num_plan_eis: Faker::Lorem.characters(10))
      lot.valid?
      expect(lot.errors[:num_plan_eis]).not_to include(SpecError.message('too_long.many', count: 20))
    end
  end
end

require 'spec_helper'

describe Contract do
  # it "#cost" do
  #   lot = create(:lot, specifications: [build(:specification, qty: 10, cost: 200.00, cost_nds: 200.00),
  #                                       build(:specification, qty: 1, cost: 4000.00, cost_nds: 4000.00)])
  #   contract = create(:contract, lot: lot)
  #   create(:contract_specification, contract: contract,
  #                                   specification: lot.specifications[0],
  #                                   cost: 180.00,
  #                                   cost_nds: 180.00)
  #   create(:contract_specification, contract: contract,
  #                                   specification: lot.specifications[1],
  #                                   cost: 3800.00,
  #                                   cost_nds: 3800.00)
  #   expect(contract.cost).to eq(5600.0)
  # end

  # it "#cost_nds" do
  #   lot = create(:lot, specifications: [build(:specification, qty: 10, cost: 200.00, cost_nds: 200.00),
  #                                       build(:specification, qty: 1, cost: 4000.00, cost_nds: 4000.00)])
  #   contract = create(:contract, lot: lot)
  #   create(:contract_specification, contract: contract, specification: lot.specifications[0], cost_nds: 180.00)
  #   create(:contract_specification, contract: contract, specification: lot.specifications[1], cost_nds: 3800.00)
  #   expect(contract.cost_nds).to eq(5600.0)
  # end

  it "end_date_bigger_then_begin_date" do
    lot = create(:lot_with_spec, tender: create(:tender))
    contract = build(:contract, delivery_date_begin: "2014-01-02", delivery_date_end: "2014-01-01", lot: lot)
    contract.valid?
    expect(contract.errors[:delivery_date_end].size).to eq(1)
  end

  describe "begin_date_bigger_then_confirm_date" do
    it "invalid" do
      lot = create(:lot_with_spec, tender: create(:tender))
      contract = build(:contract, confirm_date: "2014-01-02", delivery_date_begin: "2014-01-01", lot: lot)
      contract.valid?
      expect(contract.errors[:delivery_date_begin].size).to eq(1)
    end
    it "valid for ONLY_SOURCE" do
      lot = create(
        :lot_with_spec,
        tender: create(:tender, :only_source)
      )
      contract = build(:contract, confirm_date: "2014-01-02", delivery_date_begin: "2014-01-01", lot: lot)
      contract.valid?
      expect(contract.errors[:confirm_date].size).to eq(0)
    end
  end

  describe "valid_confirm_date" do
    let(:lot) { create(:lot_with_spec, tender: create(:tender)) }
    let(:bidder) { create(:bidder, contractor: create(:contractor)) }
  end
end

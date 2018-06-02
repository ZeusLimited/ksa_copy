require 'spec_helper'

RSpec.describe RegulationItem, type: :model do

  describe "actuals scope" do
    it "call a bunch of methods" do
      expect(RegulationItem).to receive(:where).with(is_actual: true)
      RegulationItem.actuals
    end
    it "get value" do
      ri = create(:regulation_item_with_tender_types)
      expect(RegulationItem.actuals).to eq([ri])
    end
    it "get empty" do
      ri = create(:regulation_item_with_tender_types, is_actual: false)
      expect(RegulationItem.actuals).to eq([])
    end
  end

  describe "for_type scope" do
    it "call a bunch of methods" do
      expect(RegulationItem).to receive_message_chain(:joins, :where, :order)
        .with(:tender_types)
        .with(dictionaries: { ref_id: Constants::TenderTypes::OZP })
        .with(:num)
      RegulationItem.for_type(Constants::TenderTypes::OZP)
    end
    it "get value" do
      ri = create(:regulation_item_with_tender_types)
      expect(RegulationItem.for_type(Constants::TenderTypes::OOK)).to eq([ri])
    end
    it "get empty" do
      ri = create(:regulation_item, tender_types: [Dictionary.find(Constants::TenderTypes::OOK)])
      expect(RegulationItem.for_type(Constants::TenderTypes::OZP)).to eq([])
    end
    it "get empty when huina was sent" do
      ri = create(:regulation_item_with_tender_types)
      expect(RegulationItem.for_type(0)).to eq([])
    end
  end

  describe "dep_own_item" do
    it "call a bunch of methods" do
      root_customer = build(:department, id: 2)
      expect(RegulationItem).to receive_message_chain(:joins, :where)
        .with(instance_of(String))
        .with(instance_of(String), id: root_customer.id)
      RegulationItem.dep_own_item(root_customer.id)
    end
    it "get value" do
      root_customer = build(:department, id: 2)
      ri = create(:regulation_item_with_tender_types)
      expect(RegulationItem.dep_own_item(root_customer.id)).to eq([ri])
    end
    it "get empty" do
      ri = create(:regulation_item_with_tender_types)
      expect(RegulationItem.dep_own_item(0)).to eq([ri])
    end
  end

end

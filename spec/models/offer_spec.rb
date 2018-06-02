require 'spec_helper'

describe Offer do
  let(:contractor) { create(:contractor) }
  let(:bidder) { create(:bidder, contractor: contractor) }

  describe '#num_text' do
    it 'basic' do
      expect(create(:offer, bidder: bidder, num: 0).num_text).to eq("Основная")
    end

    it 'alternate' do
      expect(create(:offer, bidder: bidder, num: 2).num_text).to eq("Альтернативная №2")
    end
  end

  # it '#original_cost' do
  #   lot = create(:lot, specifications: [build(:specification, qty: 10), build(:specification, qty: 20)])
  #   offer = create(:offer, bidder: bidder, lot: lot)
  #   create(:offer_specification, cost: 30.25, offer: offer, specification: lot.specifications[0])
  #   create(:offer_specification, cost: 10.86, offer: offer, specification: lot.specifications[1])

  #   expect(offer.original_cost).to eq(519.7)
  # end

  # it '#final_cost' do
  #   lot = create(:lot, specifications: [build(:specification, qty: 10), build(:specification, qty: 20)])
  #   offer = FactoryGirl.create(:offer, bidder: bidder, lot: lot)
  #   create(:offer_specification, final_cost: 30.25, offer: offer, specification: lot.specifications[0])
  #   create(:offer_specification, final_cost: 10.86, offer: offer, specification: lot.specifications[1])

  #   expect(offer.final_cost).to eq(519.7)
  # end

  describe '#valid_uniq_index' do
    let(:lot) { create(:lot) }
    let(:bidder) { create(:bidder) }
    let(:offer_params) { { bidder: bidder, lot: lot, num: 0 } }
    let(:offer) { build(:offer, offer_params) }
    let(:message) { "Оферта с таким номером уже существует" }
    it 'uniq' do
      create(:offer, offer_params)
      offer.valid?
      expect(offer.errors[:base]).to include(message) unless offer.type_id
    end

    it 'not unq' do
      offer.valid?
      expect(offer.errors[:base]).not_to include(message)
    end
  end

  describe "#clone" do
    let(:offer) { FactoryGirl.create(:offer, bidder: bidder) }
    it 'yes' do
      expect(offer.clone(1, 2)).to be_a_new(Offer)
    end

    it 'type_id' do
      expect(offer.clone(1, 2).type_id).to eq(1)
    end

    it 'version' do
      expect(offer.clone(1, 2).version).to eq(2)
    end
  end
end

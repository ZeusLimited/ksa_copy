require 'spec_helper'

describe WinnerProtocol do
  describe "#confirm_dates" do
    let(:lot) { create(:lot) }
    let(:wp1) { build(:winner_protocol, winner_protocol_lots: [build(:winner_protocol_lot, :winner, lot: lot)]) }
    it "returns other confirm_dates for lots in this class" do
      wp2 = create(:winner_protocol, winner_protocol_lots: [build(:winner_protocol_lot, :winner, lot: lot)])
      expect(wp1.send(:lots_confirm_dates)).to eq([wp2.confirm_date])
    end

    it "returns empty massive" do
      expect(wp1.send(:lots_confirm_dates)).to eq([])
    end
  end

  describe "#available_lots" do
    let(:lot1) { build(:lot, num: 1) }
    let(:lot2) { build(:lot, num: 2) }
    let(:wp1) { build(:winner_protocol) }
    it "return empty massive" do
      allow(wp1).to receive_message_chain(:tender, :lots, :for_winner_protocol) { [] }
      allow(wp1).to receive(:lots) { [] }
      expect(wp1.available_lots).to eq([])
    end

    it "return unique sortable array of lots" do
      allow(wp1).to receive_message_chain(:tender, :lots, :for_winner_protocol) { [lot2, lot1] }
      allow(wp1).to receive(:lots) { [lot1] }
      expect(wp1.available_lots).to eq([lot1, lot2])
    end
  end
  # it "after_save" do
  #   lot = FactoryGirl.create(:lot)
  #   FactoryGirl.create(:winner_protocol, confirm_date: "2014-03-17", lots: [lot])
  #   wp2 = FactoryGirl.create(:winner_protocol, confirm_date: "2014-03-18", lots: [lot])
  #   lot.reload
  #   expect(lot.winner_protocol_id).to eq(wp2.id)
  # end

  # it "after_destroy" do
  #   lot = FactoryGirl.create(:lot)
  #   wp = FactoryGirl.create(:winner_protocol, confirm_date: "2014-03-17", lots: [lot])
  #   lot.reload
  #   expect(lot.winner_protocol_id).to eq(wp.id)
  #   wp.destroy
  #   lot.reload
  #   expect(lot.winner_protocol_id).to be_nil
  # end

  # it "confirm_date_bigger_then_vote_date fails" do
  #   wp = FactoryGirl.build(:winner_protocol, confirm_date: "2014-03-12", vote_date: "2014-03-06")
  #   wp.valid?
  #   expect(wp.errors[:confirm_date].size).to eq(1)
  # end

  # it "confirm_date_bigger_then_vote_date passes" do
  #   wp = FactoryGirl.build(:winner_protocol, confirm_date: "2014-03-13", vote_date: "2014-03-06")
  #   wp.valid?
  #   expect(wp.errors[:confirm_date].size).to eq(0)
  # end

  # it "confirm_date_already_use fails" do
  #   lot = FactoryGirl.create(:lot_with_win_offer)
  #   FactoryGirl.create(:winner_protocol, confirm_date: "2014-03-17", lots: [lot])
  #   wp2 = FactoryGirl.build(:winner_protocol, confirm_date: "2014-03-17", lots: [lot])
  #   wp2.valid?
  #   expect(wp2.errors[:confirm_date].size).to eq(1)
  # end

  # it "confirm_date_already_use passes" do
  #   FactoryGirl.create(:winner_protocol, confirm_date: "2014-03-17")
  #   wp2 = FactoryGirl.build(:winner_protocol, confirm_date: "2014-03-17")
  #   wp2.valid?
  #   expect(wp2.errors[:confirm_date].size).to eq(0)
  # end

  # let(:message_must_have_lots) { "Должен быть выбран хотя бы один лот" }

  # it "must_have_lots fails" do
  #   wp = FactoryGirl.build(:winner_protocol, lots: [])
  #   wp.valid?
  #   expect(wp.errors[:base]).to include(message_must_have_lots)
  # end

  # it "must_have_lots passes" do
  #   wp = FactoryGirl.build(:winner_protocol)
  #   wp.valid?
  #   expect(wp.errors[:base]).not_to include(message_must_have_lots)
  # end
end

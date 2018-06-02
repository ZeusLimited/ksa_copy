require 'spec_helper'

describe ReviewProtocol do
  # it "after_save" do
  #   tender = create(:tender)
  #   lot = create(:lot, tender: tender)
  #   create(:review_protocol, tender: tender, confirm_date: "2014-03-17", review_lots: [create(:review_lot, lot: lot)])
  #   rp = create(
  #     :review_protocol,
  #     tender: tender,
  #     confirm_date: "2014-03-18",
  #     review_lots: [create(:review_lot, lot: lot)])
  #   lot.reload
  #   expect(lot.review_protocol_id).to eq(rp.id)
  # end

  # it "after_destroy" do
  #   tender = create(:tender)
  #   lot = create(:lot, tender: tender)
  #   rp = create(
  #     :review_protocol,
  #     tender: tender,
  #     confirm_date: "2014-03-17",
  #     review_lots: [create(:review_lot, lot: lot)])
  #   lot.reload
  #   expect(lot.review_protocol_id).to eq(rp.id)
  #   rp.destroy
  #   lot.reload
  #   expect(lot.review_protocol_id).to be_nil
  # end

  # it "confirm_date_already_use fails" do
  #   tender = create(:tender)
  #   lot = create(:lot, tender: tender)
  #   create(:review_protocol, tender: tender, confirm_date: "2014-03-17", review_lots: [create(:review_lot, lot: lot)])
  #   rp = build(:review_protocol, tender: tender, confirm_date: "2014-03-17",
  #              review_lots: [create(:review_lot, lot: lot)])
  #   rp.valid?
  #   expect(rp.errors[:confirm_date].size).to eq(1)
  # end

  # it "confirm_date_already_use passes" do
  #   tender = create(:tender)
  #   create(:review_protocol, tender: tender, confirm_date: "2014-03-17",
  #          review_lots: [create(:review_lot, lot: create(:lot))])
  #   rp = build(:review_protocol, tender: tender, confirm_date: "2014-03-17",
  #              review_lots: [create(:review_lot, lot: create(:lot))])
  #   rp.valid?
  #   expect(rp.errors[:confirm_date].size).to eq(0)
  # end

  let(:message_must_have_lots) { "Должен быть выбран хотя бы один лот" }

  it "must_have_lots fails" do
    rp = build(:review_protocol, tender: create(:tender), review_lots: [])
    rp.valid?
    expect(rp.errors[:base]).to include(message_must_have_lots)
  end

  # it "must_have_lots passes" do
  #   rp = build(:review_protocol, tender: create(:tender), review_lots: [create(:review_lot, lot: create(:lot))])
  #   rp.valid?
  #   expect(rp.errors[:base]).not_to include(message_must_have_lots)
  # end
end

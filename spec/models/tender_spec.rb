# frozen_string_literal: true

require 'spec_helper'
include Constants::EtpAddress
include Constants::PlanLotStatus
include Constants::TenderTypes

describe Tender do
  include_examples 'tender types'

  describe "show_official_num?" do
    let(:tender) { build(:tender, :ozp) }
    let(:tender_ss) { build :tender, :only_source }
    let(:tender_nz) { build :tender, :unregulated }
    it "always false" do
      expect(tender.show_official_num?).to be_falsey
    end
  end
  it "fails validation alternate_offer string" do
    record = Tender.new(alternate_offer: "123sfsdf")
    record.valid?
    expect(record.errors[:alternate_offer].size).to eq(1)
  end

  it "fails validation alternate_offer string" do
    record = Tender.new(alternate_offer: "123.345")
    record.valid?
    expect(record.errors[:alternate_offer].size).to eq(1)
  end

  it "passes validation alternate_offer" do
    record = Tender.new(alternate_offer: "123")
    record.valid?
    expect(record.errors[:alternate_offer].size).to eq(0)
  end

  it "etp?" do
    expect(Tender.new(etp_address_id: NOT_ETP).etp?).to be false
    expect(Tender.new(etp_address_id: B2B_ENERGO).etp?).to be true
  end

  let(:plan_lots) { create_list(:plan_lot_with_specs, 1, :agreement) }
  let(:user) do
    u = create(:user)
    u.plan_lots = plan_lots
    u
  end

  it "build_from_plan_lots" do
    tender = Tender.build_from_plan_lots(user)
    expect(tender).to be_a_new(Tender)
    expect(tender.lots.size).to eq(1)
  end

  let(:lots) do
    [create(:lot_with_spec, tender: create(:tender))]
  end

  it "build_from_tender_lots" do
    params = { lot_ids: lots.map(&:id) }

    tender = Tender.build_from_tender_lots(user, params)
    expect(tender).to be_a_new(Tender)
    expect(tender.lots.size).to eq(1)
    expect(tender.lots.first.prev_id).to eq(lots.first.id)
  end

  it "only_source?" do
    expect(Tender.new(tender_type_id: ONLY_SOURCE).only_source?).to be true
    expect(Tender.new(tender_type_id: 1).only_source?).to be false
  end

  it "self.generate copy tender" do
    lot = create(:lot_with_spec)
    params = attributes_for(
      :tender,
      lots: [create(:lot,
                    num: '1', prev_id: lot.id, plan_lot_guid: lot.guid, plan_lot_id: lot.plan_lot_id,
                    specifications: [build(:specification,
                                           prev_id: lot.specifications.first.id,
                                           plan_specification_id: lot.specifications.first.plan_specification_id)])]
    )
    expect(Tender.generate_from_copy(params)).to be_a_new(Tender)
  end

  context '#can_fetch_open_protocol_b2b?' do
    let(:tender) { build(:tender) }
    context 'when no etp_num'
     it 'return false' do
       allow(tender).to receive(:etp_num).and_return(nil)
       expect(tender.can_fetch_open_protocol_b2b?).to eq(false)
     end
    context 'when open protocol exist' do
      it 'return false' do
        op = instance_double(OpenProtocol, id: Faker::Number.number(2))
        allow(tender).to receive(:open_protocol).and_return(op)
        expect(tender.can_fetch_open_protocol_b2b?).to eq(false)
      end
    end
    context 'when not b2b' do
      it 'return false' do
        allow(tender).to receive(:etp_address_id).and_return(EtpAddress::EETP)
        expect(tender.can_fetch_open_protocol_b2b?).to eq(false)
      end
    end
    context 'when all conditions success'
    it 'return true' do
      allow(tender).to receive(:etp_num).and_return(Faker::Number.number(2))
      allow(tender).to receive(:open_protocol).and_return(nil)
      allow(tender).to receive(:etp_address_id).and_return(EtpAddress::B2B_ENERGO)
      expect(tender.can_fetch_open_protocol_b2b?).to eq(true)
    end
  end

  describe '#valid_official_site_num' do
    it 'not return error if length official_site_num less 25' do
      record = Tender.new(official_site_num: Faker::Lorem.characters(10))
      record.valid?
      expect(record.errors[:official_site_num]).not_to include(SpecError.message('too_long.many', count: 25))
    end
    it 'return error if length official_site_num more 25' do
      record = Tender.new(official_site_num: Faker::Lorem.characters(30))
      record.valid?
      expect(record.errors[:official_site_num]).to include(SpecError.message('too_long.many', count: 25))
    end
  end

  describe '#terms_violated?' do
    let(:tender) { build(:tender, :ozp) }

    it 'return true of terms violated' do
      expect(tender.terms_violated?).to be_truthy
    end
    it 'return false if terms not violated' do
      tender.announce_date = Time.now
      expect(tender.terms_violated?).to be_falsey
    end
  end

  describe 'validate b2b_classifiers' do
    let(:tender) { build(:tender, b2b_classifiers: [Faker::Number.number(2)]) }

    context 'when threre is no b2b_classifiers' do
      it 'validate ok' do
        tender.b2b_classifiers = []
        tender.valid?
        expect(tender.errors[:base]).not_to include(SpecError.model_message(:tender, :base, :b2b_classifiers_must_be_low_level))
      end
    end

    context 'when b2b_classifiers low level' do
      before(:example) { allow(B2bClassifier).to receive_message_chain(:where, :exists?).and_return(false) }
      it 'validate ok' do
        tender.valid?
        expect(tender.errors[:base]).not_to include(SpecError.model_message(:tender, :base, :b2b_classifiers_must_be_low_level))
      end
    end

    context 'when not all b2b classifiers low level' do
      before(:example) { allow(B2bClassifier).to receive_message_chain(:where, :exists?).and_return(true) }
      it 'raise error' do
        tender.valid?
        expect(tender.errors[:base]).to include(SpecError.model_message(:tender, :base, :b2b_classifiers_must_be_low_level))
      end
    end
  end



  # it "self.generate new tender from plan" do
  #   lots = plan_lots.map do |pl|
  #     l = create(:lot, plan_lot: pl)
  #     l.specifications.first.plan_specification = pl.plan_specifications.first
  #     l
  #   end
  #   params = FactoryGirl.attributes_for(:tender, lots: lots)

  #   expect(Tender.generate_from_plan(params)).to be_a_new(Tender)
  # end
end

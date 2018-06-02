require 'spec_helper'

describe Contractor do

  let(:contractor) { create(:contractor) }

  describe '.potential_bidders' do
    it "calls a bunch of methods" do
      expect(Contractor).to receive_message_chain(:contractor_names, :not_olds, :where).with('term').with(no_args).with(status: [0, 1])
      Contractor.potential_bidders('term')
    end
  end

  describe ".bidders" do
    it "calls a bunch of methods for Unregulated Tender" do
      expect(Contractor).to receive_message_chain(:contractor_names, :active, :not_olds).with('term').with(no_args)
      Contractor.bidders('term', TenderTypes::UNREGULATED)
    end
    it "calls a bunch of methods for Regulated Tender" do
      expect(Contractor).to receive_message_chain(:contractor_names, :active, :not_olds, :sme).with('term').with(no_args)
      Contractor.bidders('term', TenderTypes::OOK)
    end
  end

  describe '.reestr_file?' do
    it "calls method Check exists reestr" do
      expect(contractor.reestr_file?).to be_falsey
    end
  end

  describe '#sme_in_plan?' do
    subject { contractor.sme_in_plan? }
    context 'is_sme is nil' do
      let(:contractor) { build(:contractor, is_sme: nil) }
      it { expect(subject).to eq true }
    end

    context 'is_sme is false' do
      let(:contractor) { build(:contractor, is_sme: false) }
      it { expect(subject).to eq false }
    end

    context 'is_sme is false' do
      let(:contractor) { build(:contractor, is_sme: true) }
      it { expect(subject).to eq true }
    end
  end

  describe '#valid_ownership_id' do
    it 'not to return error_message if ownership_id is not null' do
      contractor = build(:contractor, ownership_id: Faker::Number.number(1))
      contractor.valid?
      expect(contractor.errors[:ownership_id]).not_to include(SpecError.message('blank'))
    end
    it 'return error_message if ownership_id is null' do
      contractor = build(:contractor, ownership_id: nil)
      contractor.valid?
      expect(contractor.errors[:ownership_id]).to include(SpecError.message('blank'))
    end
  end

end

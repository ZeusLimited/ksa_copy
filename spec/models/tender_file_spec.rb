# frozen_string_literal: true

require 'spec_helper'

describe TenderFile do
  let(:file_plan) { create(:tender_file, :plan) }
  let(:file_tender) { create(:tender_file, :tender) }
  let(:file_protocol) { create(:tender_file, :protocol) }
  let(:file_bidder) { create(:tender_file, :bidder) }
  let(:file_contract) { create(:tender_file, :contract) }
  let(:file_contractor) { create(:tender_file, :contractor) }
  let(:file_order) { create(:tender_file, :order) }

  describe 'area scopes' do
    describe '.plan' do
      subject { described_class.plan }

      it do
        should eq [file_plan]
        should_not include(file_tender)
        should_not include(file_protocol)
        should_not include(file_bidder)
        should_not include(file_contract)
        should_not include(file_contractor)
        should_not include(file_order)
      end
    end

    describe '.tenders' do
      subject { described_class.tenders }

      it do
        should eq [file_tender]
        should_not include(file_plan)
        should_not include(file_protocol)
        should_not include(file_bidder)
        should_not include(file_contract)
        should_not include(file_contractor)
        should_not include(file_order)
      end
    end

    describe '.protocols' do
      subject { described_class.protocols }

      it do
        should eq [file_protocol]
        should_not include(file_plan)
        should_not include(file_tender)
        should_not include(file_bidder)
        should_not include(file_contract)
        should_not include(file_contractor)
        should_not include(file_order)
      end
    end

    describe '.bidders' do
      subject { described_class.bidders }

      it do
        should eq [file_bidder]
        should_not include(file_plan)
        should_not include(file_tender)
        should_not include(file_protocol)
        should_not include(file_contract)
        should_not include(file_contractor)
        should_not include(file_order)
      end
    end

    describe '.contracts' do
      subject { described_class.contracts }

      it do
        should eq [file_contract]
        should_not include(file_plan)
        should_not include(file_tender)
        should_not include(file_protocol)
        should_not include(file_bidder)
        should_not include(file_contractor)
        should_not include(file_order)
      end
    end

    describe '.contractors' do
      subject { described_class.contractors }

      it do
        should eq [file_contractor]
        should_not include(file_plan)
        should_not include(file_tender)
        should_not include(file_protocol)
        should_not include(file_bidder)
        should_not include(file_contract)
        should_not include(file_order)
      end
    end

    describe '.orders' do
      subject { described_class.orders }

      it do
        should eq [file_order]
        should_not include(file_plan)
        should_not include(file_tender)
        should_not include(file_protocol)
        should_not include(file_bidder)
        should_not include(file_contract)
        should_not include(file_contractor)
      end
    end
  end

  describe 'unused scopes' do
    let!(:unused) { create(:tender_file, area_id: area_id) }

    describe '.unused_plan' do
      subject { described_class.unused_plan }
      let(:area_id) { Constants::TenderFileArea::PLAN_LOT }

      it do
        should eq [unused]
        should_not include(file_plan)
      end
    end

    describe '.unused_tender' do
      subject { described_class.unused_tenders }
      let(:area_id) { Constants::TenderFileArea::TENDER }

      it do
        should eq [unused]
        should_not include(file_tender)
      end
    end

    describe '.unused_bidder' do
      subject { described_class.unused_bidders }
      let(:area_id) { Constants::TenderFileArea::BIDDER }

      it do
        should eq [unused]
        should_not include(file_bidder)
      end
    end

    describe '.unused_protocol' do
      subject { described_class.unused_protocols }
      let(:area_id) { Constants::TenderFileArea::PROTOCOL }

      it do
        should eq [unused]
        should_not include(file_protocol)
      end
    end

    describe '.unused_contract' do
      subject { described_class.unused_contracts }
      let(:area_id) { Constants::TenderFileArea::CONTRACT }

      it do
        should eq [unused]
        should_not include(file_contract)
      end
    end

    describe '.unused_contractor' do
      subject { described_class.unused_contractors }
      let(:area_id) { Constants::TenderFileArea::CONTRACTOR }

      it do
        should eq [unused]
        should_not include(file_contractor)
      end
    end

    describe '.unused_order' do
      subject { described_class.unused_orders }
      let(:area_id) { Constants::TenderFileArea::ORDER }

      it do
        should eq [unused]
        should_not include(file_order)
      end
    end
  end

  describe '#update_file_attributes' do
    let(:file) { build(:tender_file) }

    before { file.send(:update_file_attributes) }

    context 'set content type' do
      it { expect(file.content_type).to eq file.document.file.content_type }
    end

    context 'set file size' do
      it { expect(file.file_size).to eq file.document.file.size }
    end

    context 'document is blank' do
      let(:file) { build(:tender_file, document: nil) }

      it { expect(file.content_type).to eq nil }
      it { expect(file.file_size).to eq nil }
    end
  end
end

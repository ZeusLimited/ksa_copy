# frozen_string_literal: true

RSpec.shared_examples 'tender types' do
  let(:object) { described_class.new(tender_type_id: tender_type_id) }
  describe "auction?" do
    subject { object.auction? }
    context 'OA' do
      let(:tender_type_id) { Constants::TenderTypes::OA }

      it { should be true }
    end

    context 'ZA' do
      let(:tender_type_id) { Constants::TenderTypes::ZA }

      it { should be true }
    end

    context 'Any others' do
      let(:tender_type_id) { Constants::TenderTypes::OOK }

      it { should be false }
    end
  end

  describe 'frame?' do
    subject { object.frame? }
    context 'ORK' do
      let(:tender_type_id) { Constants::TenderTypes::ORK }

      it { should be true }
    end

    context 'ZRK' do
      let(:tender_type_id) { Constants::TenderTypes::ZRK }

      it { should be true }
    end

    context 'Any others' do
      let(:tender_type_id) { Constants::TenderTypes::OOK }

      it { should be false }
    end
  end

  describe 'noncompetitive?' do
    subject { object.noncompetitive? }
    context 'ONLY_SOURCE' do
      let(:tender_type_id) { Constants::TenderTypes::ONLY_SOURCE }

      it { should be true }
    end

    context 'ZRK' do
      let(:tender_type_id) { Constants::TenderTypes::UNREGULATED }

      it { should be true }
    end

    context 'Any others' do
      let(:tender_type_id) { Constants::TenderTypes::OOK }

      it { should be false }
    end
  end

  describe 'only_source?' do
    subject { object.only_source? }
    context 'ONLY_SOURCE' do
      let(:tender_type_id) { Constants::TenderTypes::ONLY_SOURCE }

      it { should be true }
    end

    context 'Any others' do
      let(:tender_type_id) { Constants::TenderTypes::OOK }

      it { should be false }
    end
  end

  describe 'single_source?' do
    subject { object.single_source? }
    context 'when single source' do
      let(:tender_type_id) { Constants::TenderTypes::SINGLE_SOURCE }

      it { should be true }
    end

    context 'Any others' do
      let(:tender_type_id) { Constants::TenderTypes::OOK }

      it { should be false }
    end
  end

  describe 'ei?' do
    subject { object.ei? }
    context 'when EI' do
      let(:tender_type_id) { Constants::TenderTypes::EI.sample }

      it { should be true }
    end

    context 'Any others' do
      let(:tender_type_id) { Constants::TenderTypes::OOK }

      it { should be false }
    end
  end

  describe 'preselection?' do
    subject { object.preselection? }
    context 'PO' do
      let(:tender_type_id) { Constants::TenderTypes::PO }

      it { should be true }
    end

    context 'Any others' do
      let(:tender_type_id) { Constants::TenderTypes::OOK }

      it { should be false }
    end
  end

  describe 'regulated?' do
    subject { object.regulated? }
    context 'UNREGULATED' do
      let(:tender_type_id) { Constants::TenderTypes::UNREGULATED }

      it { should be false }
    end

    context 'Any others' do
      let(:tender_type_id) { Constants::TenderTypes::OOK }

      it { should be true }
    end
  end

  describe 'tender?' do
    subject { object.tender? }
    context 'OOK' do
      let(:tender_type_id) { Constants::TenderTypes::OOK }

      it { should be true }
    end

    context 'OMK' do
      let(:tender_type_id) { Constants::TenderTypes::OMK }

      it { should be true }
    end

    context 'OCK' do
      let(:tender_type_id) { Constants::TenderTypes::OCK }

      it { should be true }
    end

    context 'ORK' do
      let(:tender_type_id) { Constants::TenderTypes::ORK }

      it { should be true }
    end

    context 'ZOK' do
      let(:tender_type_id) { Constants::TenderTypes::ZOK }

      it { should be true }
    end

    context 'ZMK' do
      let(:tender_type_id) { Constants::TenderTypes::ZMK }

      it { should be true }
    end

    context 'ZCK' do
      let(:tender_type_id) { Constants::TenderTypes::ZCK }

      it { should be true }
    end

    context 'ZRK' do
      let(:tender_type_id) { Constants::TenderTypes::ZRK }

      it { should be true }
    end

    context 'Any others' do
      let(:tender_type_id) { Constants::TenderTypes::ZZC }

      it { should be false }
    end
  end

  describe 'unregulated?' do
    subject { object.unregulated? }
    context 'UNREGULATED' do
      let(:tender_type_id) { Constants::TenderTypes::UNREGULATED }

      it { should be true }
    end

    context 'Any others' do
      let(:tender_type_id) { Constants::TenderTypes::OOK }

      it { should be false }
    end
  end

  describe 'zc?' do
    subject { object.zc? }
    context 'OZC' do
      let(:tender_type_id) { Constants::TenderTypes::OZC }

      it { should be true }
    end

    context 'ZZC' do
      let(:tender_type_id) { Constants::TenderTypes::ZZC }

      it { should be true }
    end

    context 'Any others' do
      let(:tender_type_id) { Constants::TenderTypes::OOK }

      it { should be false }
    end
  end

  describe 'zpp?' do
    subject { object.zpp? }
    context 'ZPP' do
      let(:tender_type_id) { Constants::TenderTypes::ZPP }

      it { should be true }
    end

    context 'Any others' do
      let(:tender_type_id) { Constants::TenderTypes::OOK }

      it { should be false }
    end
  end

  describe 'zzc?' do
    subject { object.zzc? }
    context 'ZZC' do
      let(:tender_type_id) { Constants::TenderTypes::ZZC }

      it { should be true }
    end

    context 'Any others' do
      let(:tender_type_id) { Constants::TenderTypes::OOK }

      it { should be false }
    end
  end

  describe '#tender_type_etp?' do
    subject { object.tender_type_etp? }
    context 'ETP type' do
      let(:tender_type_id) { Constants::TenderTypes::ETP.sample }

      it { should be true }
    end

    context 'Any others' do
      let(:tender_type_id) { Constants::TenderTypes::NON_ETP.sample }

      it { should be false }
    end
  end

  describe '#tender_type_non_etp?' do
    subject { object.tender_type_non_etp? }
    context 'ETP type' do
      let(:tender_type_id) { Constants::TenderTypes::NON_ETP.sample }

      it { should be true }
    end

    context 'Any others' do
      let(:tender_type_id) { Constants::TenderTypes::ETP.sample }

      it { should be false }
    end
  end

  describe '#tender_type_non_sme?' do
    subject { object.tender_type_non_sme? }
    context 'ETP type' do
      let(:tender_type_id) { Constants::TenderTypes::NON_SME.sample }

      it { should be true }
    end

    context 'Any others' do
      let(:tender_type_id) { Constants::TenderTypes::SME.sample }

      it { should be false }
    end
  end
end

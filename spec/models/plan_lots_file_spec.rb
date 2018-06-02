require 'spec_helper'

describe PlanLotsFile do
  let(:plan_lots_file) { create(:plan_lots_file) }

  describe '#nmcd?' do
    subject { plan_lots_file.nmcd? }
    context 'rao' do
      context 'plan_lot_file is nmcd' do
        let(:plan_lots_file) { build(:plan_lots_file) }
        it { expect(subject).to eq true }
      end

      context 'plan_lot_file is not nmcd' do
        let(:plan_lots_file) { build(:plan_lots_file, file_type_id: 1) }
        it { expect(subject).to eq false }
      end

      context 'plan_lot_file is null' do
        let(:plan_lots_file) { build(:plan_lots_file, file_type_id: nil) }
        it { expect(subject).to eq false }
      end
    end
  end
end

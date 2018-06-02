require 'spec_helper'

RSpec.describe Commission, :type => :model do
  describe '#czk?' do
  end

  describe '#sd?' do
  end

  describe '#for_customers?' do
    subject { commission.for_customers? }
    context 'for_customers is true' do
      let(:commission) { build(:commission, for_customers: true) }
      it { expect(subject).to eq(true) }
    end

    context 'commission type is szk' do
      let(:commission) { build(:commission, :szk) }
      it { expect(subject).to eq(true) }
    end

    context 'other events' do
      let(:commission) { build(:commission, for_customers: false) }
      it { expect(subject).to eq(false) }
    end
  end

  describe '#self.for_organizer' do
  end

  describe '#commission_type_name' do
  end

  describe '#name_i' do
  end

  describe '#name_r' do
  end

  describe '#name_d' do
  end

end

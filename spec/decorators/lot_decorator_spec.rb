require 'spec_helper'

describe LotDecorator do
  let(:lot) { build(:lot).decorate }

  describe '#winner_info' do
    it "nil when there are no win offers" do
      expect(lot.winner_info).to be_nil
    end

    it "return company name and cost when we have winners" do
      offers = [instance_double(Offer, bidder_contractor_name_short: "AAA", final_cost: 4),
                instance_double(Offer, bidder_contractor_name_short: "BBB", final_cost: 6)]

      allow(lot).to receive(:win_offers) { offers }
      allow(offers).to receive(:exists?) { true }
      expect(lot.winner_info).to eq(
        "AAA<br><strong>Стоимость: 4.00</strong><br><br>BBB<br><strong>Стоимость: 6.00</strong>")
    end
  end

  describe '#consumer_shortnames' do
    subject { lot.decorate.consumer_shortnames }

    let(:lot) do
      build(:lot, specifications: [
        build(:specification, :consumer => create(:department, shortname: name1)),
        build(:specification, :consumer => create(:department, shortname: name2)),
      ])
    end
    let(:name1) { Faker::Lorem.unique.word }
    let(:name2) { Faker::Lorem.unique.word }

    context 'show names' do
      it { should eq [name1, name2] }
    end

    context 'uniq names' do
      let(:name2) { name1 }

      it { should eq [name1] }
    end
  end
end

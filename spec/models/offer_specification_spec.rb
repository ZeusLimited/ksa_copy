require 'spec_helper'

describe OfferSpecification do
  describe "#final_nds" do
    let(:spec) { build(:offer_specification, final_cost: 121, final_cost_nds: 142.78) }
    subject { spec.final_nds }
    context "return nil" do
      it "final_cost is nil" do
        spec.final_cost = nil
        expect(subject).to be_nil
      end

      it "final_cost_nds is nil" do
        spec.final_cost_nds = nil
        expect(subject).to be_nil
      end
    end

    it "return ratio between final_cost and final_cost_nds" do
      expect(subject).to eq(18.0)
    end
  end
end

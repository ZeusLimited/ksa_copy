require 'spec_helper'

describe ExpertOpinionsHelper do
  describe "class for opinion" do
    it "not class" do
      expect(helper.class_for_opinion(FactoryGirl.create(:draft_opinion))).to eq('')
    end
    it "positive class" do
      expect(helper.class_for_opinion(FactoryGirl.create(:draft_opinion, vote: true))).to eq(' positive_opinion')
    end
    it "negative class" do
      expect(helper.class_for_opinion(FactoryGirl.create(:draft_opinion, vote: false))).to eq(' negative_opinion')
    end
  end
end

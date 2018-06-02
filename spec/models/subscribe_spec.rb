require 'spec_helper'

describe Subscribe do

  describe "#plan_lot_exists?" do

    let(:plan_lot) { create(:plan_lot) }

    it "false" do
      subscribe = build(:subscribe)
      expect(subscribe.plan_lot_exists?).to be false
    end
    it "true" do
      subscribe2 = build(:subscribe, plan_lot_guid: plan_lot.guid)
      expect(subscribe2.plan_lot_exists?).to be true
    end
  end
end

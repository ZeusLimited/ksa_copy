require 'spec_helper'

describe ControlPlanLotsController do
  let(:plan_lot) { create(:plan_lot) }
  let(:cpl_attrs) do
    {
      user_id: @user.id,
      plan_lot_guid: plan_lot.guid
    }
  end

  before(:each) do
    @user = create(:user_boss)
    sign_in @user
    @user.plan_lots << plan_lot
  end

  describe "POST create_list" do
    it "success" do
      expect { post 'create_list' }.to change(ControlPlanLot, :count).by(1)
    end
  end

  describe "DELETE delete_list" do
    it "success" do
      ControlPlanLot.create! cpl_attrs
      expect { delete :delete_list }.to change(ControlPlanLot, :count).by(-1)
    end
  end
end

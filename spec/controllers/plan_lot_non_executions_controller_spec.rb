require 'spec_helper'

describe PlanLotNonExecutionsController do
  let(:plan_lot) { create(:plan_lot) }

  let(:plne_attrs) do
    attributes_for(:plan_lot_non_execution).merge(
      plan_lot_guid_hex: plan_lot.guid_hex)
  end

  before(:each) do
    @user = create(:user_user)
    sign_in @user
  end

  it "GET index" do
    get :index, params: { guid: plan_lot.guid_hex }
    expect(assigns(:plan_lot_current_version)).to eq(plan_lot)
  end

  describe "POST create" do
    it "success" do
      expect do
        post :create, params: { guid: plan_lot.guid_hex, plan_lot_non_execution: plne_attrs }
      end.to change(PlanLotNonExecution, :count).by(1)
      plne = assigns(:plan_lot_non_execution)
      expect(plne).to be_a(PlanLotNonExecution)
      expect(plne.user).to eq(@user)
      expect(plne.plan_lot_guid_hex).to eq(plan_lot.guid_hex)
      expect(plne).to be_persisted
      expect(response).to be_redirect
    end
  end
end

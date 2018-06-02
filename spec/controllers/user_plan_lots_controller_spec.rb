require 'spec_helper'

describe UserPlanLotsController do

  before(:each) do
    @user = FactoryGirl.create(:user_user)
    sign_in @user
  end

  describe "GET 'index'" do
    it "returns http success" do
      @user.plan_lots << FactoryGirl.create(:plan_lot)
      get :index, xhr: true
      expect(assigns(:plan_selected_lots).to_a).to eq(@user.plan_lots)
    end
  end

  describe "POST 'select_list'" do
    it "returns http success" do
      plan_lot = FactoryGirl.create(:plan_lot)
      post :select_list, params: { plan_lot_ids: [plan_lot.id] }, xhr: true
      expect(assigns(:plan_selected_lots).to_a).to eq([plan_lot])
    end
  end

  describe "POST 'unselect_list'" do
    it "returns http success" do
      plan_lot = FactoryGirl.create(:plan_lot)
      @user.plan_lots << plan_lot
      post :unselect_list, params: { plan_lot_ids: [plan_lot.id] }, xhr: true
      expect(assigns(:plan_selected_lots).to_a).to eq([])
    end
  end

  describe "POST 'unselect_all'" do
    it "returns http success" do
      @user.plan_lots << FactoryGirl.create(:plan_lot)
      post :unselect_all, xhr: true
      expect(assigns(:plan_selected_lots).to_a).to eq([])
    end
  end

end

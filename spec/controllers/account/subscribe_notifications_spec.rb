require 'spec_helper'

describe Account::SubscribeNotificationsController do
  before(:each) do
    @user = create(:user_user)
    sign_in @user
  end

  describe "GET index" do
    it "success" do
      get :index
      assert_response :success
    end
  end

  describe "POST send_now" do
    it "success" do
      session[:subscribe_ids] = [1]
      post :send_now
      assert_response :success
    end

    it "fail" do
      post :send_now
      assert_response :success
    end
  end
end

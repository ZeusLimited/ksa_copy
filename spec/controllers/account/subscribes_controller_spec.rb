require 'spec_helper'

describe Account::SubscribesController do
  before(:each) do
    @user = create(:user_user)
    sign_in @user
  end

  let(:plan_lot) { create(:plan_lot) }

  let(:valid_params) do
    {
      subscribe_actions_attributes: [
        {
          _destroy: false,
          action_id: Constants::SubscribeActions::CONFIRM
        },
        {
          _destroy: false,
          action_id: Constants::SubscribeActions::PUBLIC
        }
      ],
      subscribe_warnings_attributes: [
        {
          days_before: "",
          action_id: Constants::SubscribeWarnings::PUBLIC
        },
        {
          days_before: 10,
          action_id: Constants::SubscribeWarnings::OPEN
        }
      ]
    }
  end

  describe "GET index" do
    it "success" do
      get :index
      assert_response :success
    end
  end

  describe "GET new_list" do
    it "success" do
      get :new_list
      assert_response :success
    end
  end

  describe "POST create_list" do
    it "success" do
      @user.plan_lots << plan_lot
      assert_difference 'Subscribe.count' do
        post :create_list, params: { account_subscribe_form: valid_params }
      end

      assert_redirected_to account_subscribes_url
    end
  end

  describe "GET edit_list" do
    it "success" do
      subscribe = create(:subscribe, plan_lot_guid: plan_lot.guid)
      session[:subscribe_ids] = [subscribe.id]
      get :edit_list
      assert_response :success
    end

    it "fail" do
      get :edit_list
      assert_response :redirect
    end
  end

  describe "PATCH update_list" do
    it "success" do
      subscribe = create(:subscribe, plan_lot_guid: plan_lot.guid)
      session[:subscribe_ids] = [subscribe.id]
      post :update_list, params: { account_subscribe_form: valid_params }
      assert_redirected_to account_subscribes_url
    end
  end

  describe "DELETE delete_list" do
    it "success" do
      subscribe = create(:subscribe, plan_lot_guid: plan_lot.guid)
      session[:subscribe_ids] = [subscribe.id]
      assert_difference('Subscribe.count', -1) do
        delete :delete_list
      end

      assert_redirected_to account_subscribes_url
    end
  end

  describe "POST push_to_session" do
    it "success" do
      session[:subscribe_ids] = []
      post :push_to_session, params: { subscribe_ids: [1] }
      assert_response :success
    end
  end

  describe "POST pop_from_session" do
    it "success" do
      session[:subscribe_ids] = [1, 2]
      post :pop_from_session, params: { subscribe_ids: [1] }
      assert_response :success
    end
  end
end

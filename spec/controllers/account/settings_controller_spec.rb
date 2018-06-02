require 'spec_helper'

describe Account::SettingsController do
  before(:each) do
    @user = create(:user_user)
    sign_in @user
  end

  let(:plan_lot) { create(:plan_lot) }

  let(:valid_params) do
    {
      value: '10:00'
    }
  end

  let(:id) { :subscribe_send_time }

  describe "GET show" do
    it "success" do
      get :show
      assert_response :success
    end
  end

  describe "GET edit" do
    it "success" do
      get :edit, params: { id: id }
      assert_response :success
    end
  end

  describe "PATCH update" do
    it "success" do
      create(:user_config, user: @user)
      patch :update, params: { id: id, rails_settings_scoped_settings: valid_params }
      assert_redirected_to account_settings_url
    end
  end
end

require 'spec_helper'

describe Account::ProfileController do
  before(:each) do
    @user = FactoryGirl.create(:user_user)
    sign_in @user
  end

  let(:user_attrs) do
    { surname: 'Ivnov', name: 'Ivan' }
  end

  describe "GET 'show'" do
    it "returns http success" do
      get 'show'
      expect(response).to be_success
    end
  end

  describe "GET 'edit'" do
    it "returns http success" do
      get 'edit'
      expect(response).to be_success
    end
  end

  describe "GET 'update'" do
    it "success" do
      patch 'update', params: { user: user_attrs }
      user = assigns(:current_user)
      expect(user.surname).to eq('Ivnov')
      expect(response).to be_redirect
    end

    it "fail" do
      patch :update, params: { user: user_attrs.merge(login: '') }
      user = assigns(:current_user)
      expect(user).to eq(@user)
      expect(response).to render_template("edit")
    end
  end
end

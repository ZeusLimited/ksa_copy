require 'spec_helper'
include Constants

describe UserController do
  before(:each) do
    @user = FactoryGirl.create(:user_admin)
    sign_in @user
  end

  describe "GET show" do
    let(:fake) { build(:user) }
    before(:each) { allow(User).to receive(:find).and_return(fake) }

    it "make object available in view" do
      get :show, params: { format: :json, id: 1 }
      expect(assigns(:user)).to eq(fake)
    end

    it "select template for rendering" do
      get :show, params: { format: :json, id: 1 }
      expect(response).to render_template(:show)
    end
  end

end

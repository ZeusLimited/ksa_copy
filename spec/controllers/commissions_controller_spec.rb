require 'spec_helper'
include Constants

describe CommissionsController do
  before(:each) do
    @user = FactoryGirl.create(:user_admin)
    sign_in @user
  end

  describe "GET show" do
    let(:fake) { build(:commission) }
    let!(:commission) { FactoryGirl.create(:commission) }

    before(:each) { allow(Commission).to receive(:find).and_return(fake) }

    it "make object available in view" do
      get :show, params: { format: :json, id: commission.id }
      expect(assigns(:commission)).to eq(fake)
    end

    it "select template for rendering html" do
      get :show, params: { id: commission.id }
      expect(response).to render_template(:show)
    end

    it "select template for rendering json" do
      get :show, params: { format: :json, id: commission.id }
      expect(response).to render_template(:show)
    end
  end

  describe "POST Create" do
    let(:commission) { attributes_for(:commission) }
    it 'call method save' do
      expect_any_instance_of(Commission).to receive(:save)
      post :create, params: { commission: commission }
    end
    it 'redirect to index url' do
      allow_any_instance_of(Commission).to receive(:save).and_return(true)
      post :create, params: { commission: commission }
      expect(response).to redirect_to(commissions_url)
    end
    it 'render template new' do
      allow_any_instance_of(Commission).to receive(:save).and_return(false)
      post :create, params: { commission: commission }
      expect(response).to render_template(:new)
    end
  end

end

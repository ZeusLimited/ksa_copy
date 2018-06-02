require 'spec_helper'

RSpec.describe OkdpController, type: :controller do
  let!(:user) { create(:user_view) }

  before(:each) { sign_in user }

  describe "GET index" do
    before(:each) { allow(Okdp).to receive(:all).and_return(Okdp) }

    it "calls model method where" do
      expect(Okdp).to receive(:where).with(id: ["1", "2"])
      get :index, params: { format: :json, ids: "1,2" }
    end
    it "select template for rendering" do
      get :index, params: { format: :json }
      expect(response).to render_template(:index)
    end

    it "make search result available in view" do
      fake = [double(Okdp), double(Okdp)]
      allow(Okdp).to receive(:where).and_return(fake)
      get :index, params: { format: :json, ids: "1,2" }

      expect(assigns(:okdp)).to eq(fake)
    end
  end

  describe "GET nodes_for_filter" do
    it "call the same models method" do
      expect(Okdp).to receive(:nodes_for_filter).with('term', 'okdp').and_return({})
      get :nodes_for_filter, params: { format: :json, filter: 'term', type: 'okdp' }
    end

    it "rendering json results" do
      allow(Okdp).to receive(:nodes_for_filter).and_return({})
      get :nodes_for_filter, params: { format: :json, filter: 'term', type: 'okdp' }
      expect(response.body).to eq("{}")
    end
  end

  describe "GET nodes_for_parent" do
    it "call the same models method" do
      expect(Okdp).to receive_message_chain(:by_type, :nodes_for_parent).with('okdp').with(nil)
      get :nodes_for_parent, params: { format: :json, type: 'okdp' }
    end

    it "rendering json results" do
      allow(Okdp).to receive_message_chain(:by_type, :nodes_for_parent).with('okdp').with(nil).and_return(nil)
      get :nodes_for_filter, params: { format: :json, type: 'okdp' }
      expect(response.body).to eq("[]")
    end
  end

  describe "GET reform_old_value" do
    let!(:okdp) { build(:okdp) }
    it "call the same models method" do
      expect(Okdp).to receive(:reform_old_value).with(okdp.code).and_return({})
      get :reform_old_value, params: { format: :json, new_value: okdp.code }
    end

    it "rendering json results" do
      allow(Okdp).to receive(:reform_old_value).and_return({})
      get :reform_old_value, params: { format: :json, new_value: okdp.code }
      expect(response.body).to eq("{}")
    end
  end

  describe "GET show" do
    let(:fake) { build(:okdp) }
    before(:each) { allow(Okdp).to receive(:find).and_return(fake) }

    it "make object available in view" do
      get :show, params: { format: :json, id: 1 }
      expect(assigns(:okdp)).to eq(fake)
    end

    it "select template for rendering" do
      get :show, params: { format: :json, id: 1 }
      expect(response).to render_template(:show)
    end
  end
end

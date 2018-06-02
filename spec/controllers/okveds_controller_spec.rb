require 'spec_helper'

RSpec.describe OkvedsController, type: :controller do
  let(:user) { create(:user_admin) }

  before(:each) { sign_in user }

  describe "GET index" do
    before(:each) { allow(Okved).to receive(:all).and_return(Okved) }

    it "calls model method where" do
      expect(Okved).to receive(:where).with(id: ["1", "2"])
      get :index, params: { format: :json, ids: "1,2" }
    end
    it "select template for rendering" do
      get :index, params: { format: :json }
      expect(response).to render_template(:index)
    end

    it "make search result available in view" do
      fake = [double(Okved), double(Okved)]
      allow(Okved).to receive(:where).and_return(fake)
      get :index, params: { format: :json, ids: "1,2" }

      expect(assigns(:okved)).to eq(fake)
    end
  end

  describe "GET nodes_for_filter" do
    it "call the same models method" do
      expect(Okved).to receive(:nodes_for_filter).with('term', 'okved').and_return({})
      get :nodes_for_filter, params: { format: :json, filter: 'term', type: 'okved' }
    end

    it "rendering json results" do
      allow(Okved).to receive(:nodes_for_filter).and_return({})
      get :nodes_for_filter, params: { format: :json, filter: 'term', type: 'okved' }
      expect(response.body).to eq("{}")
    end
  end

  describe "GET nodes_for_parent" do
    it "call the same models method" do
      expect(Okved).to receive_message_chain(:by_type, :nodes_for_parent).with('okved').with(nil)
      get :nodes_for_parent, params: { format: :json, type: 'okved' }
    end

    it "rendering json results" do
      allow(Okved).to receive_message_chain(:by_type, :nodes_for_parent).with('okved').with(nil).and_return(nil)
      get :nodes_for_filter, params: { format: :json, type: 'okved' }
      expect(response.body).to eq("[]")
    end
  end

  describe "GET show" do
    let(:fake) { build(:okved) }
    before(:each) { allow(Okved).to receive(:find).and_return(fake) }

    it "make objec available in view" do
      get :show, params: { format: :json, id: 1 }
      expect(assigns(:okved)).to eq(fake)
    end

    it "select template for rendering" do
      get :show, params: { format: :json, id: 1 }
      expect(response).to render_template(:show)
    end
  end
end

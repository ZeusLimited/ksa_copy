require 'spec_helper'

RSpec.describe ContractorsController, type: :controller do
  let(:user) { create(:user_user) }

  let(:contractor) { create(:contractor) }

  before(:each) { sign_in(user) }

  describe "GET show" do
    it "success" do
      get :show, params: { id: contractor.id }
      assert_response :success
    end
  end

  describe "GET search_potential_bidders" do
    it "calls models method and returns contractors for plan_lots" do
      expect(Contractor).to receive(:potential_bidders).with('term')
      get :search_potential_bidders, params: { format: :json, term: 'term' }
    end
    it "selects template 'results' for rendering" do
      allow(Contractor).to receive(:potential_bidders)
      get :search_potential_bidders, params: { format: :json, term: 'term' }
      expect(response).to render_template(:results)
    end
    it "assigns variable contractors for template view" do
      fake_results = [double('Contractor'), double(Contractor)]
      allow(Contractor).to receive(:potential_bidders).and_return(fake_results)
      get :search_potential_bidders, params: { format: :json, term: 'term' }
      expect(assigns(:contractors)).to eq(fake_results)
    end
  end

  describe "GET search" do
    it "calls contractor_names, not_olds, active" do
      expect(Contractor).to receive_message_chain(:contractor_names, :not_olds, :active).with('term').with(no_args).with(no_args)
      get :search, params: { format: :json, term: 'term' }
    end
    it "selects template 'result' for rendering" do
      allow(Contractor).to receive_message_chain(:contractor_names, :not_olds, :active)
      get :search, params: { format: :json, term: 'term' }
      expect(response).to render_template(:results)
    end
    it "assign variable contractors for view" do
      fake_results = [double(Contractor), double(Contractor)]
      allow(Contractor).to receive_message_chain(:contractor_names, :not_olds, :active).and_return(fake_results)
      get :search, params: { format: :json, term: 'term' }
      expect(assigns(:contractors)).to eq(fake_results)
    end
  end

  describe "GET search_bidders" do
    it "call model method .bidders" do
      expect(Contractor).to receive(:bidders).with("123", 123)
      get :search_bidders, params: { format: :json, term: "123", tender_type_id: "123" }
    end
    it "selects 'results' template for rendering" do
      allow(Contractor).to receive(:bidders)
      get :search_bidders, params: { format: :json, term: "123", tender_type_id: "123" }
      expect(response).to render_template("results")
    end
    it "assign variable contractors for view" do
      fake_results = [double(Contractor), double(Contractor)]
      allow(Contractor).to receive(:bidders).and_return(fake_results)
      get :search_bidders, params: { format: :json, term: "123", tender_type_id: "123" }
      expect(assigns(:contractors)).to eq(fake_results)
    end
  end
end

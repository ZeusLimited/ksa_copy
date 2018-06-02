require 'spec_helper'

describe TendersController do
  let(:user) { create(:user_user) }
  let(:tender_rp) { create(:tender_with_rp_sign_lot) }

  before(:each) { sign_in(user) }

  describe "GET index" do
    let(:fake_results) { double(ActiveRecord::Relation) }
    let(:tender_filter) { instance_double(TenderFilter, search: fake_results) }

    it "call method new in TenderFilter" do
      expect(TenderFilter).to receive(:new).with(nil)
      get :index
    end

    context "select template for rendering" do
      before(:each) { allow(TenderFilter).to receive(:new) }
      it "html" do
        get :index
        expect(response).to render_template(:index)
      end
      it "json" do
        get :index, format: :json
        expect(response).to render_template(:index)
      end
    end

    it "results are available on view" do
      allow(TenderFilter).to receive(:new).and_return(tender_filter)
      allow(tender_filter).to receive(:search).and_return(fake_results)
      allow(fake_results).to receive(:page).and_return(fake_results)
      get :index, params: { tender_filter: { gkpz_year: [2017] } }
      expect(assigns(:tenders)).to eq(fake_results)
    end
  end

  describe "GET show" do
    let!(:tender) { create(:tender) }

    context "select html template" do
      subject { tender.decorate }
      it "regulated_tender" do
        allow_any_instance_of(TenderDecorator).to receive(:show_template).and_return(:show)
        get :show, params: { id: tender.to_param }
        expect(response).to render_template(:show)
      end
      it "unregulated_tender without contract" do
        allow_any_instance_of(TenderDecorator).to receive(:show_template).and_return(:show)
        get :show, params: { id: subject.to_param }
        expect(response).to render_template(:show)
      end
      it "unregulated_tender with contract" do
        allow_any_instance_of(TenderDecorator).to receive(:show_template).and_return(:show_unregulated)
        get :show, params: { id: tender.to_param }
        expect(response).to render_template(:show_unregulated)
      end
    end
    it "render json object" do
      allow_any_instance_of(Tender).to receive(:as_json).and_return(object = double)
      get :show, params: { id: tender.to_param, format: :json }
      expect(response.body).to eq(object.to_json)
    end
  end

  describe "GET contracts" do
    it "success" do
      get :contracts, params: { id: tender_rp.id }
      assert_response :success
    end
  end

  # Try to fix CircleCI
  # describe "GET show_standard_form" do
  #   it "success" do
  #     get :show_standard_form, params: { id: tender_rp.id, format: :docx, template: 'notice.docx' }
  #     assert_response :success
  #   end
  # end
end

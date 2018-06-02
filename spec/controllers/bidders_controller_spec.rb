require 'spec_helper'

describe BiddersController do
  before(:each) do
    @user = FactoryGirl.create(:user_admin)
    sign_in @user
  end

  let(:tender) { FactoryGirl.create(:tender) }
  let(:contractor) { FactoryGirl.create(:contractor) }
  let(:bidder) { create(:bidder, contractor: contractor, tender: tender) }
  let(:valid_attributes) do
    {
      tender_id: tender.id,
      contractor_id: contractor.id
    }
  end

  describe "GET index" do
    it "assigns all bidders as @bidders" do
      bidder = Bidder.create! valid_attributes
      get :index, params: { tender_id: tender.id }
      expect(assigns(:bidders)).to eq([bidder])
    end

    it "returns http success" do
      get 'index', params: { tender_id: tender.id }
      expect(response).to be_success
    end
  end

  describe "GET show" do
    it "assigns the requested bidder as @bidder" do
      bidder = Bidder.create! valid_attributes
      get :show, params: { tender_id: tender.id, id: bidder.to_param }
      expect(assigns(:bidder)).to eq(bidder)
    end

    it "returns http success" do
      bidder = Bidder.create! valid_attributes
      get :show, params: { tender_id: tender.id, id: bidder.id }
      expect(response).to be_success
    end
  end

  describe "GET new" do
    it "assigns a new bidder as @bidder" do
      get :new, params: { tender_id: tender.id }
      expect(assigns(:bidder)).to be_a_new(Bidder)
    end

    it "returns http success" do
      get :new, params: { tender_id: tender.id }
      expect(response).to be_success
    end
  end

  describe "GET edit" do
    it "assigns the requested bidder as @bidder" do
      bidder = Bidder.create! valid_attributes
      get :edit, params: { tender_id: tender.id, id: bidder.to_param }
      expect(assigns(:bidder)).to eq(bidder)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Bidder" do
        expect do
          post :create, params: { tender_id: tender.id, bidder: valid_attributes }
        end.to change(Bidder, :count).by(1)
      end

      it "assigns a newly created bidder as @bidder" do
        post :create, params: { tender_id: tender.id, bidder: valid_attributes }
        expect(assigns(:bidder)).to be_a(Bidder)
        expect(assigns(:bidder)).to be_persisted
      end

      it "redirects to the created bidder" do
        post :create, params: { tender_id: tender.id, bidder: valid_attributes }
        expect(response).to redirect_to(tender_bidders_path(tender))
      end
    end

    it "fail" do
      post :create, params: { tender_id: tender.id, bidder: valid_attributes.merge(contractor_id: nil) }
      assert_template :new
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "assigns the requested bidder as @bidder" do
        bidder = Bidder.create! valid_attributes
        patch :update, params: { tender_id: tender.id, id: bidder.to_param, bidder: valid_attributes }
        expect(assigns(:bidder)).to eq(bidder)
      end

      it "redirects to the bidder" do
        bidder = Bidder.create! valid_attributes
        patch :update, params: { tender_id: tender.id, id: bidder.to_param, bidder: valid_attributes }
        expect(response).to redirect_to(tender_bidder_path(tender, bidder))
      end
    end

    it "fail" do
      patch :update, params: {
        tender_id: tender.id, id: bidder.to_param, bidder: valid_attributes.merge(contractor_id: nil)
      }
      assert_template :edit
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested bidder" do
      bidder = Bidder.create! valid_attributes
      expect do
        delete :destroy, params: { tender_id: tender.id, id: bidder.to_param }
      end.to change(Bidder, :count).by(-1)
    end

    it "redirects to the bidders list" do
      bidder = Bidder.create! valid_attributes
      delete :destroy, params: { tender_id: tender.id, id: bidder.to_param }
      expect(response).to redirect_to(tender_bidders_url(tender))
    end
  end

  describe "GET map_pivot" do
    it "assigns all bidders as @bidders" do
      bidder = Bidder.create! valid_attributes
      get :map_pivot, params: { tender_id: tender.id }
      expect(assigns(:bidders)).to eq([bidder])
    end

    it "returns http success" do
      get 'map_pivot', params: { tender_id: tender.id }
      expect(response).to be_success
    end
  end

  describe "GET map_by_lot" do
    it "assigns all bidders as @bidders" do
      bidder = Bidder.create! valid_attributes
      get :map_by_lot, params: { tender_id: tender.id }
      expect(assigns(:bidders)).to eq([bidder])
    end

    it "returns http success" do
      get 'map_by_lot', params: { tender_id: tender.id }
      expect(response).to be_success
    end
  end
end

require 'spec_helper'

describe ContentOffersController do
  before(:each) do
    @user = FactoryGirl.create(:user_admin)
    sign_in @user
  end

  let(:valid_attributes) do
    FactoryGirl.attributes_for(:content_offer).merge(content_offer_type_id: ContentOfferType::HR)
  end

  describe "GET index" do
    it "assigns all content_offers as @content_offers" do
      content_offer = FactoryGirl.create(:content_offer)
      get :index
      expect(assigns(:content_offers)).to eq([content_offer])
    end
  end

  describe "GET show" do
    it "assigns the requested content_offer as @content_offer" do
      content_offer = FactoryGirl.create(:content_offer)
      get :show, params: { id: content_offer.to_param }
      expect(assigns(:content_offer)).to eq(content_offer)
    end
  end

  describe "GET new" do
    it "assigns a new content_offer as @content_offer" do
      get :new
      expect(assigns(:content_offer)).to be_a_new(ContentOffer)
    end
  end

  describe "GET edit" do
    it "assigns the requested content_offer as @content_offer" do
      content_offer = FactoryGirl.create(:content_offer)
      get :edit, params: { id: content_offer.to_param }
      expect(assigns(:content_offer)).to eq(content_offer)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new ContentOffer" do
        expect do
          post :create, params: { content_offer: valid_attributes }
        end.to change(ContentOffer, :count).by(1)
      end

      it "assigns a newly created content_offer as @content_offer" do
        post :create, params: { content_offer: valid_attributes }
        expect(assigns(:content_offer)).to be_a(ContentOffer)
        expect(assigns(:content_offer)).to be_persisted
      end

      it "redirects to the created content_offer" do
        post :create, params: { content_offer: valid_attributes }
        expect(response).to redirect_to(ContentOffer.last)
      end
    end

    describe "with invalid params" do
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "assigns the requested content_offer as @content_offer" do
        content_offer = FactoryGirl.create(:content_offer)
        put :update, params: { id: content_offer.to_param, content_offer: valid_attributes }
        expect(assigns(:content_offer)).to eq(content_offer)
      end

      it "redirects to the content_offer" do
        content_offer = FactoryGirl.create(:content_offer)
        put :update, params: { id: content_offer.to_param, content_offer: valid_attributes }
        expect(response).to redirect_to(content_offer)
      end
    end

    describe "with invalid params" do
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested content_offer" do
      content_offer = FactoryGirl.create(:content_offer)
      expect do
        delete :destroy, params: { id: content_offer.to_param }
      end.to change(ContentOffer, :count).by(-1)
    end

    it "redirects to the content_offers list" do
      content_offer = FactoryGirl.create(:content_offer)
      delete :destroy, params: { id: content_offer.to_param }
      expect(response).to redirect_to(content_offers_url)
    end
  end
end

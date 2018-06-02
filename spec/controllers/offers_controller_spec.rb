require 'spec_helper'
include Constants

describe OffersController do
  before(:each) do
    @user = FactoryGirl.create(:user_admin)
    sign_in @user
  end

  let!(:tender) { FactoryGirl.create(:tender) }
  let(:lot) { FactoryGirl.create(:lot_with_spec, tender: tender) }
  let(:contractor) { FactoryGirl.create(:contractor) }
  let!(:bidder) { FactoryGirl.create(:bidder, tender: tender, contractor: contractor) }
  let(:offer) { create(:offer, bidder: bidder) }
  let!(:offer_pickup) { create(:offer, :pickup, bidder: bidder) }

  let(:valid_attributes) do
    {
      bidder_id: bidder.id,
      lot_id: lot.id,
      status_id: OfferStatuses::NEW,
      type_id: OfferTypes::OFFER,
      num: 0,
      version: 0,
      conditions: "abc"
    }
  end
  let(:invalid_attributes) do
    {
      bidder_id: bidder.id,
      lot_id: lot.id,
      type_id: OfferTypes::OFFER,
      num: 0,
      version: 0,
      conditions: "abc"
    }
  end
  let(:valid_add_attributes) do
    {
      bidder_id: bidder.id,
      lot_id: lot.id,
      status_id: OfferStatuses::NEW,
      type_id: OfferTypes::REPLACE,
      num: 0,
      version: 0,
      conditions: "abc"
    }
  end
  let(:valid_pickup_attributes) do
    {
      bidder_id: bidder.id,
      lot_id: lot.id,
      status_id: OfferStatuses::NEW,
      type_id: OfferTypes::PICKUP,
      num: 0,
      version: 0,
      conditions: "abc"
    }
  end

  before(:each) do
    allow(Tender).to receive(:find).and_return(tender)
    allow(tender).to receive_message_chain(:bidders, :find).and_return(bidder)
  end

  describe "GET index" do
    it "receive lots from tender" do
      expect(bidder).to receive(:offers)
      expect(tender).to receive_message_chain(:lots, :order).with(no_args).with(:num)
      get :index, params: { tender_id: tender.id, bidder_id: bidder.id }
    end

    it "assigns all lots as @lots" do
      allow(tender).to receive_message_chain(:lots, :order).and_return(lots = double)
      get :index, params: { tender_id: tender.id, bidder_id: bidder.id }
      expect(assigns(:lots)).to eq(lots)
    end

    context "select template for rendering" do
      before(:each) { allow(tender).to receive_message_chain(:lots, :order) }
      it "html" do
        get :index, params: { tender_id: tender.id, bidder_id: bidder.id }
        expect(response).to render_template(:index)
      end
      it "json" do
        get :index, params: { tender_id: tender.id, bidder_id: bidder.id, format: :json }
        expect(response).to render_template(:index)
      end
    end
  end

  describe "GET show" do
    context "select template for rendering" do
      before(:each) { allow(tender).to receive_message_chain(:lots, :order) }
      it "html" do
        get :index, params: { tender_id: tender.id, bidder_id: bidder.id, offer_id: offer.id }
        expect(response).to render_template(:index)
      end
      it "json" do
        get :index, params: { tender_id: tender.id, bidder_id: bidder.id, offer_id: offer.id, format: :json }
        expect(response).to render_template(:index)
      end
    end
  end

  describe "GET new" do
    it "receive offer from bidder" do
      expect(bidder).to receive(:build_offer).with(lot.to_param)
      get :new, params: { tender_id: tender.id, bidder_id: bidder.id, lot_id: lot.id }
    end

    it "assigns offers as @offer" do
      allow(bidder).to receive(:build_offer).and_return(offer = double)
      get :new, params: { tender_id: tender.id, bidder_id: bidder.id }
      expect(assigns(:offer)).to eq(offer)
    end

    context "select template for rendering" do
      let(:fake) { build(:lot) }
      before(:each) { allow(Lot).to receive(:find).and_return(fake) }
      it "html" do
        get :new, params: { tender_id: tender.id, bidder_id: bidder.id }
        expect(response).to render_template(:new)
      end
      it "json" do
        get :new, params: { tender_id: tender.id, bidder_id: bidder.id, format: :json }
        expect(response).to render_template(:show)
      end
    end
  end

  describe "POST create" do
    it "save element" do
      expect_any_instance_of(Offer).to receive(:save)
      post :create, params: { tender_id: tender.id, bidder_id: bidder.id, offer: valid_attributes }
    end
    context "render uses format" do
      it "save equal true render html" do
        allow_any_instance_of(Offer).to receive(:save).and_return(true)
        post :create, params: { tender_id: tender.id, bidder_id: bidder.id, offer: attributes_for(:offer) }
        expect(response).to redirect_to assigns(:show)
      end
      it "save equal false render html" do
        allow_any_instance_of(Offer).to receive(:save).and_return(false)
        post :create, params: { tender_id: tender.id, bidder_id: bidder.id, offer: attributes_for(:offer) }
        expect(response).to render_template(:new)
      end

      it "save equal true render json" do
        allow_any_instance_of(Offer).to receive(:save).and_return(true)
        post :create, params: {
          tender_id: tender.id, bidder_id: bidder.id, offer: attributes_for(:offer), format: :json
        }
        expect(response).to render_template(:show)
        expect(response.status).to eq(201)
      end
      it "save equal false render json" do
        allow_any_instance_of(Offer).to receive(:save).and_return(false)
        post :create, params: { tender_id: tender.id, bidder_id: bidder.id, offer: invalid_attributes, format: :json }
        expect(response.body).to eq("{}")
        expect(response.status).to eq(422)
      end
    end
  end

  describe "GET edit" do
    context "check status pickup" do
      it "fail" do
        get :edit, params: { tender_id: tender.id, bidder_id: bidder.id, id: offer_pickup.id }
        expect(response).to redirect_to :root
      end
      it "success" do
        get :edit, params: { tender_id: tender.id, bidder_id: bidder.id, id: offer.id }
        expect(response).to render_template(:edit)
      end
    end

    context "select template for rendering" do
      it "html" do
        get :edit, params: { tender_id: tender.id, bidder_id: bidder.id, id: offer.id }
        expect(response).to render_template(:edit)
      end
      it "json" do
        get :edit, params: { tender_id: tender.id, bidder_id: bidder.id, id: offer.id, format: :json }
        expect(response).to render_template(:show)
      end
    end
  end

  describe "Bidders actions" do
    let!(:offer_old) { create(:offer, bidder: bidder, lot: lot) }
    let!(:offer_old_pickup) { create(:offer, :pickup, bidder: bidder, lot: lot) }

    describe "GET control" do
      it "when offer_old is nil" do
        allow(Offer).to receive_message_chain(:for_bid_lot_num, :where, :first) { nil }
        get :control, params: { tender_id: tender.id, bidder_id: bidder.id, lot_id: lot.to_param, num: offer_old.num }
        expect(response).to redirect_to :root
      end
      it "expect receive next_type" do
        allow(Offer).to receive_message_chain(:for_bid_lot_num, :where, :first) { offer_old }
        expect(offer_old).to receive(:next_type).with(no_args)
        get :control, params: { tender_id: tender.id, bidder_id: bidder.id, lot_id: lot.to_param, num: offer_old.num }
      end

      context "get offer_old" do
        it "receive new offer from clone offer_old" do
          allow(Offer).to receive_message_chain(:for_bid_lot_num, :where, :first) { offer_old }
          allow(offer_old).to receive(:next_type).and_return(offer_type = double)
          expect(offer_old).to receive(:clone).with(offer_type)
          get :control, params: {
            tender_id: tender.id, bidder_id: bidder.id, lot_id: lot.to_param, num: offer_old.num
          }
        end

        it "assigns offers as @offer" do
          allow(Offer).to receive_message_chain(:for_bid_lot_num, :where, :first) { offer_old }
          allow(offer_old).to receive(:next_type).and_return(offer_type = double)
          allow(offer_old).to receive(:clone).with(offer_type).and_return(offer_old)
          get :control, params: {
            tender_id: tender.id, bidder_id: bidder.id, lot_id: lot.to_param, num: offer_old.num
          }
          expect(assigns(:offer)).to eq(offer_old)
        end
      end

      context "select template for rendering" do
        it "html" do
          get :control, params: {
            tender_id: tender.id, bidder_id: bidder.id, lot_id: lot.to_param, num: offer_old.num
          }
          expect(response).to render_template(:control)
        end
        it "json" do
          get :control, params: {
            tender_id: tender.id, bidder_id: bidder.id, lot_id: lot.to_param, num: offer_old.num, format: :json
          }
          expect(response).to render_template(:show)
        end
      end
    end

    describe "POST pickup" do
      context "testing when pickup" do
        it "when offer_old is nil" do
          allow(Offer).to receive_message_chain(:for_bid_lot_num, :where, :first) { nil }
          post :pickup, params: {
            tender_id: tender.id, bidder_id: bidder.id, lot_id: lot.to_param, num: offer_old.num
          }
          expect(response).to redirect_to :root
        end
        it "expect receive next_type" do
          allow(Offer).to receive_message_chain(:for_bid_lot_num, :where, :first) { offer_old_pickup }
          post :pickup, params: {
            tender_id: tender.id, bidder_id: bidder.id, lot_id: lot.to_param, num: offer_old.num
          }
        end

        context "get offer_old" do
          before(:each) { allow(Offer).to receive_message_chain(:for_bid_lot_num, :where, :first) { offer_old } }
          it "receive new offer from clone offer_old" do
            allow(offer_old).to receive(:clone).with(OfferTypes::PICKUP).and_return(offer_old)
            expect(offer_old).to receive(:clone).with(OfferTypes::PICKUP)
            post :pickup, params: {
              tender_id: tender.id, bidder_id: bidder.id, lot_id: lot.to_param, num: offer_old.num
            }
          end

          it "assigns offers as @offer" do
            allow(offer_old).to receive(:clone).with(OfferTypes::PICKUP).and_return(offer_old)
            post :pickup, params: {
              tender_id: tender.id, bidder_id: bidder.id, lot_id: lot.to_param, num: offer_old.num
            }
            expect(assigns(:offer)).to eq(offer_old)
          end
        end

        context "render uses format" do
          before(:each) { allow(Offer).to receive_message_chain(:for_bid_lot_num, :where, :first) { offer_old } }
          it "save element" do
            expect_any_instance_of(Offer).to receive(:save)
            post :pickup, params: {
              tender_id: tender.id, bidder_id: bidder.id, lot_id: lot.to_param, num: offer_old.num,
              offer: valid_pickup_attributes
            }
          end
          it "save equal true render html" do
            allow_any_instance_of(Offer).to receive(:save).and_return(true)
            post :pickup, params: {
              tender_id: tender.id, bidder_id: bidder.id, lot_id: lot.to_param, num: offer_old.num,
              offer: valid_pickup_attributes
            }
            expect(response).to redirect_to tender_bidder_offers_url
          end
          it "save equal false render html" do
            allow_any_instance_of(Offer).to receive(:save).and_return(false)
            post :pickup, params: {
              tender_id: tender.id, bidder_id: bidder.id, lot_id: lot.to_param, num: offer_old.num,
              offer: invalid_attributes
            }
            expect(response).to redirect_to tender_bidder_offers_url
          end

          it "save equal true render json" do
            allow_any_instance_of(Offer).to receive(:save).and_return(true)
            post :pickup, params: {
              tender_id: tender.id, bidder_id: bidder.id, lot_id: lot.to_param, num: offer_old.num,
              offer: valid_pickup_attributes, format: :json
            }
            expect(response).to render_template(:show)
            expect(response.status).to eq(201)
          end
          it "save equal false render json" do
            allow_any_instance_of(Offer).to receive(:save).and_return(false)
            post :pickup, params: {
              tender_id: tender.id, bidder_id: bidder.id, lot_id: lot.to_param, num: offer_old.num,
              offer: invalid_attributes, format: :json
            }
            expect(response.body).to eq("{}")
            expect(response.status).to eq(422)
          end
        end
      end
    end
  end

  describe "PATCH update" do
    context "success" do
      it "success" do
        expect_any_instance_of(Offer).to receive(:update_attributes)
        patch :update, params: { tender_id: tender.id, bidder_id: bidder.id, id: offer.id, offer: valid_attributes }
      end
      it "update equal true render html" do
        allow_any_instance_of(Offer).to receive(:update_attributes).and_return(true)
        patch :update, params: { tender_id: tender.id, bidder_id: bidder.id, id: offer.id, offer: valid_attributes }
        expect(response).to redirect_to tender_bidder_offer_url
      end
      it "update equal true render json" do
        allow_any_instance_of(Offer).to receive(:update_attributes).and_return(true)
        patch :update, params: {
          tender_id: tender.id, bidder_id: bidder.id, id: offer.id, offer: valid_attributes, format: :json
        }
        expect(response.body).to eq("")
      end
    end
    context "fail" do
      it "update equal false render html" do
        allow_any_instance_of(Offer).to receive(:update_attributes).and_return(false)
        patch :update, params: { tender_id: tender.id, bidder_id: bidder.id, id: offer.id, offer: invalid_attributes }
        expect(response).to render_template(:edit)
      end
      it "update equal false render json" do
        allow_any_instance_of(Offer).to receive(:update_attributes).and_return(false)
        patch :update, params: { tender_id: tender.id, bidder_id: bidder.id, id: offer.id, offer: invalid_attributes }
        expect(response.body).to eq("")
      end
    end

  end


  describe "DELETE destroy" do
    it "delete element" do
      expect_any_instance_of(Offer).to receive(:destroy)
      delete :destroy, params: { tender_id: tender.id, bidder_id: bidder.id, id: offer.to_param }
    end
    it "redirect to html" do
      allow_any_instance_of(Offer).to receive(:destroy)
      delete :destroy, params: { tender_id: tender.id, bidder_id: bidder.id, id: offer.to_param }
      expect(response).to redirect_to tender_bidder_offers_url
    end
    it "render json" do
      allow_any_instance_of(Offer).to receive(:destroy)
      delete :destroy, params: { tender_id: tender.id, bidder_id: bidder.id, id: offer.to_param, format: :json }
      expect(response.body).to eq("")
    end
  end

  describe "POST add" do
    describe "with valid params" do
      it "creates a new Offer" do
        offer_old = Offer.create! valid_attributes
        expect do
          post :add, params: {
            tender_id: tender.id,
            bidder_id: bidder.id,
            lot_id: offer_old.lot_id,
            num: offer_old.num,
            offer: valid_add_attributes
          }
        end.to change(Offer, :count).by(1)
      end

      it "assigns a newly created offer as @offer" do
        offer_old = Offer.create! valid_attributes
        post :add, params: {
          tender_id: tender.id,
          bidder_id: bidder.id,
          lot_id: offer_old.lot_id,
          num: offer_old.num,
          offer: valid_add_attributes
        }
        expect(assigns(:offer)).to be_a(Offer)
        expect(assigns(:offer)).to be_persisted
      end

      it "redirects to the created offer" do
        offer_old = Offer.create! valid_attributes
        post :add, params: {
          tender_id: tender.id,
          bidder_id: bidder.id,
          lot_id: offer_old.lot_id,
          num: offer_old.num,
          offer: valid_add_attributes
        }
        expect(response).to redirect_to(tender_bidder_offers_path(tender, bidder))
      end
    end
  end
end

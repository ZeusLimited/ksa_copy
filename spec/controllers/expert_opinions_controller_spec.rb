require 'spec_helper'

describe ExpertOpinionsController do
  before(:each) do
    @user = FactoryGirl.create(:user_admin)
    sign_in @user
  end

  let(:tender) { FactoryGirl.create(:tender) }
  let(:contractor) { FactoryGirl.create(:contractor) }
  let(:offer) do
    FactoryGirl.create(:offer, bidder: FactoryGirl.create(:bidder, tender: tender, contractor: contractor))
  end
  let(:tender_draft_criterion) { FactoryGirl.create(:tender_draft_criterion, tender: tender) }
  let(:expert) { FactoryGirl.create(:expert, tender: tender, user: FactoryGirl.create(:user)) }

  let(:valid_attributes) do
    {
      criterion_id: tender_draft_criterion.id,
      expert_id: expert.id,
      offer_id: offer.id,
      vote: true,
      description: "text"
    }
  end

  describe "GET 'index'" do
    it "returns http success" do
      get 'index', params: { tender_id: tender.id }
      expect(response).to be_success
    end
  end

  describe "GET 'show_draft'" do
    it "returns http success" do
      @expert = FactoryGirl.create(:expert, tender: tender, user: FactoryGirl.create(:user))
      get 'show_draft', params: { tender_id: tender.id, id: offer.id, expert_id: @expert.id }
      expect(response).to be_success
    end
  end

  describe "GET 'edit_draft'" do
    it "returns http success" do
      @expert = FactoryGirl.create(:expert, tender: tender, user: @user,
                                            destinations: [Dictionary.find(Destinations::TEX)])
      get 'edit_draft', params: { tender_id: tender.id, id: offer.id }
      expect(response).to be_success
    end
  end

  describe "POST 'update_draft'" do
    describe "with valid params" do
      it "creates a new draft_opinion" do
        expect do
          post 'update_draft', params: { tender_id: tender.id, id: offer.id, draft_opinion: valid_attributes }
        end.to change(DraftOpinion, :count).by(1)
      end

      it "assigns a newly created draft_opinion as @draft_opinion" do
        post 'update_draft', params: { tender_id: tender.id, id: offer.id, draft_opinion: valid_attributes }
        expect(assigns(:draft_opinion)).to be_a(DraftOpinion)
        expect(assigns(:draft_opinion)).to be_persisted
      end

      it "redirects to the created draft_opinion" do
        post 'update_draft', params: { tender_id: tender.id, id: offer.id, draft_opinion: valid_attributes }
        expect(response).to have_text(" ")
      end
    end
  end
end

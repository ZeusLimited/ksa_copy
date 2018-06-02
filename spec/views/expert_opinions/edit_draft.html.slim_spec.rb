require 'spec_helper'

describe "expert_opinions/edit_draft.html.slim" do
  let(:contractor) { FactoryGirl.create(:contractor) }
  let(:bidder) { FactoryGirl.create(:bidder, contractor: contractor) }
  let(:tender_draft_criterion) { FactoryGirl.create(:contractor) }
  before(:each) do
    @user = FactoryGirl.create(:user)
    @tender = assign(:tender, FactoryGirl.create(:tender))
    tender_draft_criterion = FactoryGirl.create(:tender_draft_criterion, tender: @tender)
    draft_opinions = FactoryGirl.create_list(:draft_opinion, 3, draft_criterion: tender_draft_criterion)
    @offer = assign(:offer, FactoryGirl.create(:offer, bidder: bidder, draft_opinions: draft_opinions))
    assign(:expert, FactoryGirl.create(:expert, tender: @tender, user: @user))
  end

  it "renders attributes" do
    render
  end
end

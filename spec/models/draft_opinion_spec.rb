require 'spec_helper'

describe DraftOpinion do
  it "" do
    dr = FactoryGirl.build(:draft_opinion, draft_criterion: FactoryGirl.build(:tender_draft_criterion, name: 'xxx'))
    expect(dr.draft_criterion_name).to eq('xxx')
  end

  it "get_or_new return new" do
    criterion_id = 1
    offer_id = 1
    expert_id = 1

    expect(DraftOpinion.get_or_new(criterion_id, expert_id, offer_id)).to be_a_new(DraftOpinion)
  end

  it "get_or_new return get" do
    criterion_id = 1
    offer_id = 1
    expert_id = 1
    FactoryGirl.create(:draft_opinion, criterion_id: criterion_id, expert_id: expert_id, offer_id: offer_id)

    expect(DraftOpinion.get_or_new(criterion_id, expert_id, offer_id)).to be_a(DraftOpinion)
    expect(DraftOpinion.get_or_new(criterion_id, expert_id, offer_id)).to be_persisted
  end

end

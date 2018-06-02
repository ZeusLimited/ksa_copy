require 'spec_helper'

describe "expert_opinions/index.html.slim" do
  before(:each) do
    @tender = assign(:tender, FactoryGirl.create(:tender_with_lots))
    assign(:experts, FactoryGirl.build_list(:expert, 3, tender: @tender))
  end

  it "renders attributes" do
    render
  end
end

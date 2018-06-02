require 'spec_helper'

describe "Tenders" do
  before(:each) do
    sign_in_as_admin
    @tender = FactoryGirl.create(:tender)
  end

  # describe "GET /tenders" do
  #   it "displays empty tenders" do
  #     get tenders_path
  #     expect(response.body).not_to include("Найденно закупок")
  #     expect(response.status).to eq(200)
  #   end
end

require 'spec_helper'

describe HistoriesController do
  before(:each) do
    @user = create(:user_user)
    sign_in @user
  end

  let(:tender) { create(:tender) }

  describe "index" do
    it "success" do
      get :index, params: { type: tender.class.name, item_id: tender.id }
      t = assigns(:object)
      expect(t).to eq(tender)
      expect(response).to be_success
    end
  end
end

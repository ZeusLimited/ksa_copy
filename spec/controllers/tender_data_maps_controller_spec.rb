require 'spec_helper'

RSpec.describe TenderDataMapsController, type: :controller do
  let(:user) { create(:user_user) }
  let(:tender_rp) { create(:tender_with_rp_sign_lot) }

  let(:valid_attributes) do
    { alternate_offer: 55, alternate_offer_aspects: 'Аспекты', is_gencontractor: true }
  end

  before(:each) { sign_in(user) }

  describe "GET show" do
    it "success" do
      get :show, params: { tender_id: tender_rp.id }
      assert_response :success
    end
  end

  describe "GET edit" do
    it "success" do
      get :edit, params: { tender_id: tender_rp.id }
      assert_response :success
    end
  end

  describe "GET update" do
    it "success" do
      patch :update, params: { tender_id: tender_rp.id, tender: valid_attributes }
      assert_redirected_to tender_tender_data_map_url(tender_rp)
    end
  end
end

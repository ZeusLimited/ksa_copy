require 'spec_helper'

RSpec.describe ContractExpiredsController, type: :controller do
  let(:user) { create(:user_user) }

  let(:tender) { create(:tender_with_rp_sign_lot) }
  let(:offer) { tender.lots[0].offers[0] }

  let(:valid_params) do
    {
      non_contract_reason: 'abc'
    }
  end

  before(:each) { sign_in(user) }

  describe "GET edit" do
    it "success" do
      get :edit, params: { offer_id: offer.id }
      assert_response :success
    end
  end

  describe "PATCH update" do
    it "success" do
      patch :update, params: { offer_id: offer.id, offer: valid_params }
      assert_response :success
      assert_equal 'abc', @response.body
    end
  end
end

require 'spec_helper'

RSpec.describe ContractsController, type: :controller do
  let(:user) { create(:user_user) }

  let(:tender_win) { create(:tender_with_winner_lot) }
  let(:tender_rp) { create(:tender_with_rp_sign_lot) }
  let(:tender_contract) { create(:tender_with_contract_lot) }

  let(:valid_params) do
    {
      parent_id: "",
      num: "333",
      confirm_date: "19.05.2015",
      delivery_date_begin: "20.05.2015",
      delivery_date_end: "22.05.2015",
      contract_specifications_attributes: {
        '0' => {
          specification_id: first_spec(tender_rp).id.to_s,
          cost_money: "1 000.00",
          cost_nds_money: "1 180.00",
          contract_amounts_attributes: {
            '0' => {
              _destroy: "false",
              year: "2015",
              amount_finance_money: "1 000.00",
              amount_finance_nds_money: "1 180.00"
            }
          }
        }
      },
      non_delivery_reason: "abc"
    }
  end
  let(:invalid_params) { valid_params.merge(num: "") }

  def first_lot(tender)
    tender.lots[0]
  end

  def first_spec(tender)
    tender.lots[0].specifications[0]
  end

  def first_offer(tender)
    tender.lots[0].offers[0]
  end

  before(:each) { sign_in(user) }

  describe "GET show" do
    it "success" do
      get :show, params: { offer_id: first_offer(tender_contract).id }
      assert_response :success
    end
  end

  describe "GET new" do
    it "success" do
      get :new, params: { offer_id: first_offer(tender_rp).id }
      assert_response :success
    end

    it "fail" do
      get :new, params: { offer_id: first_offer(tender_win).id }
      assert_response :redirect
    end
  end

  describe "POST create" do
    it "success" do
      offer = first_offer(tender_rp)
      assert_difference 'Contract.count' do
        post :create, params: { offer_id: offer.id, contract: valid_params }
      end

      assert_redirected_to offer_contract_path(first_offer(tender_rp))
    end

    it "non valid" do
      offer = first_offer(tender_rp)
      assert_no_difference 'Contract.count' do
        post :create, params: { offer_id: offer.id, contract: invalid_params }
      end

      assert_template :new
    end
  end

  describe "GET edit" do
    it "success" do
      get :edit, params: { offer_id: first_offer(tender_contract).id }
      assert_response :success
    end
  end

  describe "PATCH update" do
    it "success" do
      patch :update, params: { offer_id: first_offer(tender_contract).id, contract: valid_params }
      assert_redirected_to offer_contract_path(first_offer(tender_contract))
    end

    it "non valid" do
      patch :update, params: { offer_id: first_offer(tender_contract).id, contract: invalid_params }
      assert_template :edit
    end
  end

  describe "DELETE destroy" do
    it "success" do
      offer = first_offer(tender_contract)
      assert_difference('Contract.count', -1) do
        delete :destroy, params: { offer_id: offer.id }
      end

      assert_redirected_to contracts_tender_path(tender_contract)
    end
  end

  describe "GET additional_search" do
    it "success" do
      get :additional_search, params: { format: :json, offer_id: first_offer(tender_win).id, q: 'foo' }
      assert_response :success
    end
  end

  describe "GET additional_info" do
    it "success" do
      get :additional_info, params: {
        format: :json,
        offer_id: first_offer(tender_win).id,
        id: first_offer(tender_contract).contract.id
      }
      assert_response :success
    end
  end
end

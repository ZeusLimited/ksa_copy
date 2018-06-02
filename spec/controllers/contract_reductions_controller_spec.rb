require 'spec_helper'

RSpec.describe ContractReductionsController, type: :controller do
  let(:user) { create(:user_user) }

  let(:tender_contract) { create(:tender_with_contract_lot) }
  let(:spec) { tender_contract.lots[0].specifications[0] }
  let(:contract_basic) { tender_contract.lots[0].offers[0].contract }
  let(:lot) { tender_contract.lots[0] }
  let(:spec) { lot.specifications[0] }
  let(:offer) { lot.offers[0] }
  let(:contract_reduction) { create(:contract_with_spec, :reduction, lot: lot, offer: offer) }
  let(:cs_reduction) { contract_reduction.contract_specifications[0] }

  let(:valid_params) do
    {
      num: "33",
      confirm_date: "27.05.2015",
      delivery_date_begin: "28.05.2015",
      delivery_date_end: "29.05.2015",
      contract_specifications_attributes: {
        '0' => {
          specification_id: spec.id,
          cost_money: "200.00",
          cost_nds_money: "300.00"
        }
      }
    }
  end
  let(:invalid_params) { valid_params.merge(num: '') }
  let(:update_valid_params) do
    valid_params.merge(contract_specifications_attributes: { '0' => { id: cs_reduction.id } })
  end

  before(:each) { sign_in(user) }

  describe "GET index" do
    it "success" do
      get :index, params: { contract_id: contract_basic.id }
      assert_response :success
    end
  end

  describe "GET show" do
    it "success" do
      get :show, params: { contract_id: contract_basic.id, id: contract_reduction.id }
      assert_response :success
    end
  end

  describe "GET new" do
    it "success" do
      get :new, params: { contract_id: contract_basic.id }
      assert_response :success
    end
  end

  describe "POST create" do
    it "success" do
      contract_id = contract_basic.id
      assert_difference 'Contract.count' do
        post :create, params: { contract_id: contract_id, contract: valid_params }
      end

      assert_redirected_to contract_contract_reduction_path(contract_basic, Contract.last)
    end

    it "non valid" do
      contract_id = contract_basic.id
      assert_no_difference 'Contract.count' do
        post :create, params: { contract_id: contract_id, contract: invalid_params }
      end

      assert_template :new
    end
  end

  describe "GET edit" do
    it "success" do
      get :edit, params: { contract_id: contract_basic.id, id: contract_reduction.id }
      assert_response :success
    end
  end

  describe "PATCH update" do
    it "success" do
      patch :update, params: {
        contract_id: contract_basic.id, id: contract_reduction.id, contract: update_valid_params
      }
      assert_redirected_to contract_contract_reduction_path(contract_basic, contract_reduction)
    end

    it "non valid" do
      patch :update, params: {  contract_id: contract_basic.id, id: contract_reduction.id, contract: invalid_params }
      assert_template :edit
    end
  end

  describe "DELETE destroy" do
    it "success" do
      contract_id = contract_basic.id
      contract_reduction_id = contract_reduction.id
      assert_difference('Contract.count', -1) do
        delete :destroy, params: { contract_id: contract_id, id: contract_reduction_id }
      end

      assert_redirected_to contract_contract_reductions_path(contract_basic)
    end
  end
end

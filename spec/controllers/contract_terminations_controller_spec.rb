require 'spec_helper'

RSpec.describe ContractTerminationsController, type: :controller do
  let(:user) { create(:user_user) }

  let(:tender_contract) { create(:tender_with_contract_lot) }
  let(:contract) { tender_contract.lots[0].offers[0].contract }
  let(:contract_termination) { create(:contract_termination, contract: contract) }

  let(:valid_params) do
    {
      type_id: ContractTerminationTypes::AGREEMENT,
      cancel_date: "25.05.2015",
      unexec_cost_money: "200.00"
    }
  end
  let(:invalid_params) { valid_params.merge(cancel_date: nil) }

  before(:each) { sign_in(user) }

  describe "GET show" do
    it "success" do
      get :show, params: { contract_id: contract.id }
      assert_response :success
    end
  end

  describe "GET new" do
    it "success" do
      get :new, params: { contract_id: contract.id }
      assert_response :success
    end
  end

  describe "POST create" do
    it "success" do
      assert_difference 'ContractTermination.count' do
        post :create, params: { contract_id: contract.id, contract_termination: valid_params }
      end

      assert_redirected_to contract_contract_termination_url(contract)
    end

    it "non valid" do
      assert_no_difference 'ContractTermination.count' do
        post :create, params: { contract_id: contract.id, contract_termination: invalid_params }
      end

      assert_template :new
    end
  end

  describe "GET edit" do
    it "success" do
      get :edit, params: { contract_id: contract.id, id: contract_termination.id }
      assert_response :success
    end
  end

  describe "PATCH update" do
    it "success" do
      patch :update, params: {
        contract_id: contract.id, id: contract_termination.id, contract_termination: valid_params
      }
      assert_redirected_to contract_contract_termination_url(contract)
    end

    it "non valid" do
      patch :update, params: {
        contract_id: contract.id, id: contract_termination.id, contract_termination: invalid_params
      }
      assert_template :edit
    end
  end

  describe "DELETE destroy" do
    it "success" do
      contract_termination_id = contract_termination.id
      assert_difference('ContractTermination.count', -1) do
        delete :destroy, params: { contract_id: contract.id, id: contract_termination_id }
      end

      assert_redirected_to offer_contract_url(contract.offer)
    end
  end
end

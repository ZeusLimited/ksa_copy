require 'spec_helper'

RSpec.describe SubContractorsController, type: :controller do
  let(:user) { create(:user_user) }

  let(:tender_contract) { create(:tender_with_contract_lot) }
  let(:spec) { tender_contract.lots[0].specifications[0] }
  let(:contract) { tender_contract.lots[0].offers[0].contract }
  let(:cs) { contract.contract_specifications[0] }
  let(:contractor) { create(:contractor) }
  let(:sub_contractor) { create(:sub_contractor, contract: contract, contractor: contractor) }

  let(:valid_params) do
    {
      contractor_id: contractor.id,
      sub_contractor_specs_attributes: {
        '0' => {
          specification_id: spec.id,
          contract_specification_id: cs.id,
          cost_money: "500.00",
          cost_nds_money: "600.00"
        }
      }
    }
  end
  let(:invalid_params) { valid_params.merge(contractor_id: nil) }

  before(:each) { sign_in(user) }

  describe "GET index" do
    it "success" do
      get :index, params: { contract_id: contract.id }
      assert_response :success
    end
  end

  describe "GET show" do
    it "success" do
      get :show, params: { contract_id: contract.id, id: sub_contractor.id }
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
      assert_difference 'SubContractor.count' do
        post :create, params: { contract_id: contract.id, sub_contractor: valid_params }
      end

      assert_redirected_to contract_sub_contractor_path(contract, SubContractor.last)
    end

    it "non valid" do
      assert_no_difference 'SubContractor.count' do
        post :create, params: { contract_id: contract.id, sub_contractor: invalid_params }
      end

      assert_template :new
    end
  end

  describe "GET edit" do
    it "success" do
      get :edit, params: { contract_id: contract.id, id: sub_contractor.id }
      assert_response :success
    end
  end

  describe "PATCH update" do
    it "success" do
      patch :update, params: { contract_id: contract.id, id: sub_contractor.id, sub_contractor: valid_params }
      assert_redirected_to contract_sub_contractor_path(contract, sub_contractor)
    end

    it "non valid" do
      patch :update, params: { contract_id: contract.id, id: sub_contractor.id, sub_contractor: invalid_params }
      assert_template :edit
    end
  end

  describe "DELETE destroy" do
    it "success" do
      sub_contractor_id = sub_contractor.id
      assert_difference('SubContractor.count', -1) do
        delete :destroy, params: { contract_id: contract.id, id: sub_contractor_id }
      end

      assert_redirected_to contract_sub_contractors_path(contract)
    end
  end
end

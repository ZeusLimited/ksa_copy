require 'spec_helper'

RSpec.describe UnfairContractorsController, type: :controller do
  let(:user) { create(:user_user) }
  let(:moderator) { create(:user_moderator) }
  let(:unfair) { create(:unfair_contractor) }
  let(:lot) { create(:lot_with_spec) }
  let(:contractor) { create(:contractor) }

  let(:valid_attributes) do
    attributes_for(:unfair_contractor).merge(lot_ids: lot.id).merge(contractor_id: contractor.id)
  end

  let(:invalid_attributes) { attributes_for(:unfair_contractor).merge(num: nil) }

  describe "USER action" do
    before(:each) do
      sign_in(user)
    end

    describe "GET #index" do
      it "success" do
        get :index
        assert_response :success
      end
    end

    describe "GET #show" do
      it "success" do
        get :show, params: { id: unfair.id }
        assert_response :success
      end
    end
  end

  describe "Moderator Actions" do
    before(:each) do
      sign_in(moderator)
    end

    describe "GET #new" do
      it "success" do
        get :new
        assert_response :success
      end
    end
    describe "GET #edit" do
      it "success" do
        get :edit, params: { id: unfair.id }
        assert_response :success
      end
    end
    describe "POST #create" do
      it "success" do
        assert_difference 'UnfairContractor.count' do
          post :create, params: { unfair_contractor: valid_attributes }
        end
        assert_redirected_to unfair_contractor_url(UnfairContractor.last)
      end

      it "fail" do
        assert_no_difference 'UnfairContractor.count' do
          post :create, params: { unfair_contractor: invalid_attributes }
        end
        assert_template :new
      end
    end
    describe "PATCH #update" do
      it "success" do
        patch :update, params: { id: unfair.to_param, unfair_contractor: { num: '2' } }
        assert_redirected_to unfair_contractor_url
      end

      it "fail" do
        patch :update, params: { id: unfair.to_param, unfair_contractor: invalid_attributes }
        assert_template :edit
      end
    end

    describe "DELETE #destroy" do
      it "success" do
        unfair.id
        assert_difference('UnfairContractor.count', -1) do
          delete :destroy, params: { id: unfair.to_param }
        end
        assert_redirected_to unfair_contractors_url
      end
    end

    describe "GET lots" do
      it "success" do
        get :lots, params: { format: :json, name: 'Аринк', contractor_id: contractor.id }
        assert_response :success
      end
    end

    describe "GET lots_info" do
      it "success" do
        get :lots_info, params: { format: :json, lot_id: lot.id.to_s }
        assert_response :success
      end
    end

    describe "GET export_excel" do
      it "success" do
        get :export_excel, params: { format: :xlsx }
        assert_response :success
      end
    end
  end
end

require 'spec_helper'

RSpec.describe TenderDatesForTypesController, type: :controller do
  let(:user) { create(:user_user) }
  let(:moderator) { create(:user_moderator) }
  let!(:tdft) { create(:tender_dates_for_type) }

  let(:valid_attributes) { attributes_for(:tender_dates_for_type) }

  let(:invalid_attributes) { attributes_for(:tender_dates_for_type).merge(tender_type_id: nil) }

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
        get :edit, params: { id: tdft.id }
        assert_response :success
      end
    end

    describe "POST #create" do
      it "success" do
        assert_difference 'TenderDatesForType.count' do
          post :create, params: { tender_dates_for_type: valid_attributes }
        end
        assert_redirected_to tender_dates_for_types_path
      end
    end

    describe "PATCH #update" do
      it "success" do
        patch :update, params: { id: tdft.to_param, tender_dates_for_type: { days: Faker::Number.number(1) } }
        assert_redirected_to tender_dates_for_types_path
      end
    end

    describe "DELETE #destroy" do
      it "success" do
        assert_difference('TenderDatesForType.count', -1) do
          delete :destroy, params: { id: tdft.to_param }
        end
        assert_redirected_to tender_dates_for_types_path
      end
    end
  end
end

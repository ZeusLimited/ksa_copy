require 'spec_helper'

RSpec.describe OwnershipsController, type: :controller do
  let(:user) { create(:user_user) }
  let(:moderator) { create(:user_moderator) }
  let(:ownership) { create(:ownership) }

  let(:valid_attributes) do
    attributes_for(:ownership)
  end

  let(:invalid_attributes) do
    attributes_for(:ownership).merge(shortname: nil)
  end

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

    describe "POST #create" do
      it "success" do
        assert_difference 'Ownership.count' do
          post :create, params: { ownership: valid_attributes }
        end
        assert_response :success
      end

      it "fail" do
        assert_no_difference 'Ownership.count' do
          post :create, params: { ownership: invalid_attributes }
        end
        assert_response :unprocessable_entity
      end
    end

    describe "PATCH #update" do
      it "success" do
        patch :update, params: {
          id: ownership.to_param, ownership: { shortname: 'ooo', fullname: 'Company with responsibility' }
        }
        # assert_redirected_to ownerships_url
        assert_response :success
      end

      it "fail" do
        patch :update, params: { id: ownership.to_param, ownership: invalid_attributes }
        assert_response :unprocessable_entity
      end
    end

    describe "DELETE #destroy" do
      it "success" do
        ownership_id = ownership.id
        assert_difference('Ownership.count', -1) do
          delete :destroy, params: { id: ownership.to_param }
        end
        assert_response :success
      end
    end
  end
end

require 'spec_helper'

RSpec.describe ContractorDocumentsController, type: :controller do

  before(:each) do
    @user = create(:user_user)
    sign_in @user
  end

  let(:contractor) { create(:contractor) }

  let(:valid_attributes) {
    attributes_for(:contractor_file)
  }

  describe "USER action" do
    describe "GET #index" do
      it "success" do
        get :index, params: { contractor_id: contractor.id }
        assert_response :success
      end
    end

    describe "GET #edit_all" do
      it "success" do
        get :edit_all, params: { contractor_id: contractor.id }
        assert_response :success
      end
    end

    describe "PATCH #update_all" do
      it "success" do
        patch :update_all, params: {
          contractor_id: contractor.id, contractor: { files_attributes: [valid_attributes] }
        }
        assert_redirected_to contractor_documents_url(contractor)
      end
    end
  end
end

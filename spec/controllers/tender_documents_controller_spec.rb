require 'spec_helper'

RSpec.describe TenderDocumentsController, type: :controller do
  before(:each) do
    @user = FactoryGirl.create(:user_user)
    sign_in @user
  end

  let(:tender) { FactoryGirl.create(:tender) }

  let(:valid_attributes) { build(:link_tender_file) }

  describe "USER action" do
    describe "PATCH #update_all" do
      it "success" do
        patch :update_all, params: {
          tender_id: tender.id, tender: { link_tender_files_attributes: [valid_attributes] }
        }
        assert_redirected_to tender_tender_documents_url(tender)
      end
    end

    describe "GET #index" do
      it "success" do
        get :index, params: { tender_id: tender.id }
        assert_response :success
      end
    end

    describe "GET #edit_all" do
      it "success" do
        get :edit_all, params: { tender_id: tender.id }
        assert_response :success
      end
    end
  end
end

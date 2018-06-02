require 'spec_helper'

RSpec.describe MainContactsController, type: :controller do
  let(:user) { create(:user_user) }
  let(:moderator) { create(:user_moderator) }
  let(:contact) { create(:main_contact) }

  let(:valid_attributes) do
    attributes_for(:main_contact).merge(user_id: user.id)
  end

  describe "USER_action" do
    before(:each) do
      sign_in(user)
    end

    describe "GET #index" do
      it "success" do
        get :index
        assert_response :success
      end
    end

    describe "GET #new" do
      it "not render new" do
        get :new
        assert_response :redirect
      end
    end

    describe "POST #create" do
      it "fail to create" do
        assert_no_difference('MainContact.count') do
          post :create, params: { main_contact: valid_attributes }
        end
        assert_response :redirect
      end
    end

    describe "DELETE #destroy" do
      it "fail to destroy" do
        main_contact_id = contact.id
        assert_no_difference('MainContact.count') do
          delete :destroy, params: { id: main_contact_id }
        end
        assert_response :redirect
      end
    end

    describe "POST #sort" do
      it "fail to sort" do
        post :sort, params: { data: [contact.id] }
        assert_response :redirect
      end
    end
  end

  describe "MODERATOR_action" do
    before(:each) do
      sign_in(moderator)
    end

    describe "GET #index" do
      it "success" do
        get :index
        assert_response :success
      end
    end

    describe "GET #new" do
      it "success render new" do
        get :new
        assert_response :success
      end
    end

    describe "POST #create" do
      it "create" do
        assert_difference('MainContact.count', +1) do
          post :create, params: { main_contact: valid_attributes }
        end
        assert_redirected_to main_contacts_path
      end
    end

    describe "DELETE #destroy" do
      it "destroy" do
        main_contact_id = contact.id
        assert_difference('MainContact.count', -1) do
          delete :destroy, params: { id: main_contact_id }
        end
        assert_response :success
      end
    end

    describe "POST #sort" do
      it "sort" do
        post :sort, params: { data: [contact.id] }
        assert_response :success
      end
    end
  end
end

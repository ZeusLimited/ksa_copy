require 'spec_helper'

RSpec.describe MonitorServicesController, type: :controller do
  let(:user) { create(:user_user) }
  let(:moderator) { create(:user_moderator) }
  let(:mon_service) { create(:monitor_service) }

  let(:valid_attributes) do
    attributes_for(:monitor_service)
  end

  let(:invalid_attributes) do
    attributes_for(:monitor_service).merge(department_id: nil)
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
        assert_difference 'MonitorService.count' do
          post :create, params: { monitor_service: valid_attributes }
        end
      end

      it "fail" do
        assert_no_difference 'MonitorService.count' do
          post :create, params: { monitor_service: invalid_attributes }
        end
      end
    end

    describe "DELETE #destroy" do
      it "success" do
        department_id = mon_service.id
        assert_difference('MonitorService.count', -1) do
          delete :destroy, params: { id: mon_service.to_param }
        end
      end
    end
  end

end

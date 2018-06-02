require 'spec_helper'

RSpec.describe OkdpSmeEtpsController, type: :controller do

  let(:user) { create(:user_user) }
  let(:boss) { create(:user_boss) }
  let(:okdp_sme_etp) { create(:okdp_sme_etp) }

  let(:valid_attributes) do
    attributes_for(:okdp_sme_etp)
  end

  let(:invalid_attributes) do
    attributes_for(:okdp_sme_etp).merge(okdp_type: nil)
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

  describe "User boss Actions" do
    before(:each) do
      sign_in(boss)
    end

    describe "GET #new" do
      it "success" do
        get :new
        assert_response :success
      end
    end

    describe "POST #create" do
      it "success" do
        assert_difference 'OkdpSmeEtp.count' do
          post :create, params: { okdp_sme_etp: valid_attributes }
        end
        assert_redirected_to okdp_sme_etps_url
      end

      it "fail" do
        assert_no_difference 'OkdpSmeEtp.count' do
          post :create, params: { okdp_sme_etp: invalid_attributes }
        end
        assert_template :new
      end
    end

    describe "GET #edit" do
      it "success" do
        get :edit, params: { id: okdp_sme_etp.to_param }
        assert_response :success
      end
    end

    describe "PATCH #update" do
      it "success" do
        patch :update, params: { id: okdp_sme_etp.to_param, okdp_sme_etp: { okdp_type: 'Etp' } }
        assert_redirected_to okdp_sme_etps_url
      end

      it "fail" do
        patch :update, params: { id: okdp_sme_etp.to_param, okdp_sme_etp: invalid_attributes }
        assert_template :edit
      end
    end

    describe "DELETE #destroy" do
      it "success" do
        okdp_sme_etp_id = okdp_sme_etp.id
        assert_difference('OkdpSmeEtp.count', -1) do
          delete :destroy, params: { id: okdp_sme_etp.to_param }
        end
        assert_redirected_to okdp_sme_etps_path
      end
    end
  end
end

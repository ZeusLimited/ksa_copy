require 'spec_helper'

describe EffeciencyIndicatorsController, type: :controller do
  let(:user) { create(:user_user) }
  let(:user_moderator) { create(:user_moderator) }
  let(:effeciency_indicator) { create(:effeciency_indicator) }
  let(:valid_params) do
    {
      gkpz_year: Time.current.year,
      work_name: "single_source",
      name: "test_name2",
      value: 55.0
    }
  end
  let(:invalid_params) { valid_params.merge(value: 'wrong_number') }

  describe "USER Actions" do
    before(:each) do
      create(:effeciency_indicator_type)
      sign_in user
    end

    describe "GET index" do
      it "success" do
        get :index
        assert_response :success
      end
    end

    describe "POST create" do
      it "fail" do
        assert_no_difference 'EffeciencyIndicator.count' do
          post :create, params: { effeciency_indicator: valid_params }
        end
      end
    end

    describe "GET new" do
      it "fail" do
        get :new
        assert_response :redirect
      end
    end

    describe "GET edit" do
      it "fail" do
        get :edit, params: { id: effeciency_indicator.id }
        assert_response :redirect
      end
    end

    describe "PATCH update" do
      it "fail" do
        patch :update, params: { id: effeciency_indicator.id, effeciency_indicator: valid_params }
        assert_response :redirect
      end
    end

    describe "DELETE destroy" do
      it "fail" do
        id = effeciency_indicator.id
        assert_no_difference 'EffeciencyIndicator.count' do
          delete :destroy, params: { id: id }
        end
      end
    end
  end

  describe "USER_MODERATOR Actions" do
    before(:each) do
      create(:effeciency_indicator_type)
      sign_in user_moderator
    end

    describe "GET index" do
      it "success" do
        get :index
        assert_response :success
      end
    end

    describe "POST create" do
      it "success" do
        assert_difference 'EffeciencyIndicator.count' do
          post :create, params: { effeciency_indicator: valid_params }
        end
      end

      it "fail" do
        assert_no_difference 'EffeciencyIndicator.count' do
          post :create, params: { effeciency_indicator: invalid_params }
        end
      end
    end

    describe "GET new" do
      it "success" do
        get :new
        assert_response :success
      end
    end

    describe "GET edit" do
      it "success" do
        get :edit, params: { id: effeciency_indicator.id }
        assert_response :success
      end
    end

    describe "PATCH update" do
      it "success" do
        patch :update, params: { id: effeciency_indicator.id, effeciency_indicator: valid_params }
        redirect_to :index
      end

      it "fail" do
        post :update, params: { id: effeciency_indicator.id, effeciency_indicator: invalid_params }
        redirect_to :edit
      end
    end

    describe "DELETE destroy" do
      it "success" do
        id = effeciency_indicator.id
        assert_difference('EffeciencyIndicator.count', -1) do
          delete :destroy, params: { id: id }
        end
      end
    end
  end
end

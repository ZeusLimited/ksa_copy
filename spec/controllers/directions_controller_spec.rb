require 'spec_helper'
RSpec.describe DirectionsController, type: :controller do
  let(:user) { create(:user_user) }
  let(:moderator) { create(:user_moderator) }
  let(:direction) { create(:direction) }
  # This should return the minimal set of attributes required to create a valid
  # Direction. As you add validations to Direction, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    attributes_for(:direction)
  end

  let(:invalid_attributes) do
    attributes_for(:direction).merge(name: nil)
  end

  describe "USER Actions" do
    before(:each) do
      sign_in(user)
    end

    describe "GET #index" do
      it "assigns all directions as @directions" do
        get :index
        assert_response :success
      end
    end

    describe "GET #show" do
      it "assigns the requested direction as @direction" do
        get :show, params: { id: direction.id }
        assert_response :success
      end
    end
  end

  describe "MODER actions" do
    before(:each) do
      sign_in(moderator)
    end

    describe "GET #new" do
      it "assigns a new direction as @direction" do
        get :new
        assert_response :success
      end
    end

    describe "GET #edit" do
      it "success" do
        get :edit, params: { id: direction.to_param }
        assert_response :success
      end
    end

    describe "POST #create" do
      it "success" do
        assert_difference 'Direction.count' do
          post :create, params: { direction: valid_attributes }
        end
        assert_redirected_to direction_url(Direction.last)
      end

      it "fail" do
        assert_no_difference 'Direction.count' do
          post :create, params: { direction: invalid_attributes }
        end
        assert_template :new
      end
    end

    describe "PATCH #update" do
      it "success" do
        patch :update, params: { id: direction.to_param, direction: { name: '2' } }
        assert_redirected_to direction_url
      end

      it "fail" do
        patch :update, params: { id: direction.to_param, direction: invalid_attributes }
        assert_template :edit
      end
    end

    describe "DELETE #destroy" do
      it "success" do
        direction_id = direction.id
        assert_difference('Direction.count', -1) do
          delete :destroy, params: { id: direction_id }
        end
        assert_redirected_to directions_url
      end
    end

    describe "POST sort" do
      let(:direction2) { create(:direction) }

      it "success" do
        post :sort, params: { direction: [direction2.id, direction.id] }
        assert_response :success
      end
    end
  end
end

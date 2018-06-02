require 'spec_helper'

RSpec.describe DepartmentsController, type: :controller do
  let(:user) { create(:user_moderator) }

  let(:dept) { create(:department) }

  let(:address) { create(:fias) }

  let(:valid_params) do
    {
      inn: "2801133630",
      kpp: "272401001",
      ownership_id: 2,
      name: "РАО ЭС Востока",
      fullname: "ОАО РАО ЭС Востока",
      parent_dept_id: "",
      is_organizer: "1",
      is_customer: "1",
      tender_cost_limit_money: "0.00",
      position: "2",
      contact_attributes: {
        department_id: "2",
        phone: "+7 4212 26-44-03",
        fax: "+7 4212 26-44-02",
        web: "www.rao-esv.ru",
        email: "rao-esv@rao-esv.ru",
        legal_fias_id: address.id,
        postal_fias_id: address.id
      }
    }
  end

  let(:invalid_params) { valid_params.merge(inn: "") }

  before(:each) do
    sign_in(user)
  end

  describe "GET index" do
    it "success" do
      get :index
      assert_response :success
    end
  end

  describe "GET new" do
    it "success" do
      get :new
      assert_response :success
    end
  end

  describe "GET new_child" do
    it "success" do
      get :new_child
      assert_response :success
    end
  end

  describe "POST create" do
    it "success" do
      assert_difference 'Department.count' do
        post :create, params: { department: valid_params }
      end
    end

    it "non valid" do
      assert_no_difference 'Department.count' do
        post :create, params: { department: invalid_params }
      end
    end
  end

  describe "GET edit" do
    it "success" do
      get :edit, params: { id: dept.id }
      assert_response :success
    end
  end

  describe "GET edit_child" do
    it "success" do
      get :edit_child, params: { id: dept.id }
      assert_response :success
    end
  end

  describe "PATCH update" do
    it "success" do
      patch :update, params: { id: dept.id, department: valid_params }
      assert_redirected_to departments_path
    end

    it "non_valid" do
      patch :update, params: { id: dept.id, department: invalid_params }
      assert_template :edit
    end
  end

  describe "GET search" do
    it "success" do
      get :search, params: { format: :json, term: 'foo' }
      assert_response :success
    end
  end

  describe "GET nodes_for_index" do
    it "success" do
      get :nodes_for_index, params: { format: :json }
      assert_response :success
    end
  end

  describe "GET nodes_for_filter" do
    it "success" do
      get :nodes_for_filter, params: { format: :json }
      assert_response :success
    end
  end
end

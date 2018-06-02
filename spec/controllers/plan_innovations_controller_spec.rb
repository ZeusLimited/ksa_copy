require 'spec_helper'

RSpec.describe PlanInnovationsController, type: :controller do
  let(:user) { create(:user_user) }
  let(:plan_lot) { create(:plan_lot, :innovation) }

  let(:plan_innovation) do
    attributes_for(:plan_lot)
      .merge(plan_specifications_attributes: [build(:plan_specification).attributes])
      .merge(announce_year: 2020)
      .merge(delivery_year_begin: 2020)
      .merge(delivery_year_end: 2020)
  end

  before(:each) do
    create(:unit, :default_unit)
    sign_in(user)
  end

  describe "GET show" do
    it "success" do
      get :show, params: { id: plan_lot.id }
      assert_response :success
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
      get :edit, params: { id: plan_lot.id }
      assert_response :success
    end
  end

  describe "POST create" do
    it "success" do
      assert_difference 'PlanLot.count' do
        post :create, params: { plan_lot: plan_innovation }
      end
      assert_redirected_to plan_innovation_url(PlanLot.last)
    end

    it "fail" do
      assert_no_difference 'PlanLot.count' do
        post :create, params: { plan_lot: plan_innovation.merge(num_tender: nil) }
      end
      assert_template :new
    end
  end

  describe "PATCH update" do
    it "success" do
      patch :update, params: { id: plan_lot.to_param, plan_lot: plan_innovation }
      assert_redirected_to plan_innovation_url(PlanLot.last)
    end

    it "fail" do
      patch :update, params: { id: plan_lot.to_param, plan_lot: plan_innovation.merge(num_tender: nil) }
      assert_template :edit
    end
  end
end

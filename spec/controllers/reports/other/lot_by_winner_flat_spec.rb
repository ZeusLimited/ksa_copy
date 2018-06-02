require 'spec_helper'

RSpec.describe Reports::Other::LotByWinnerFlatController, type: :controller do
  let(:user) { create(:user_user) }
  let(:customer) { create(:department) }

  let(:p) do
    {
      date_begin: '01.01.2016',
      date_end: '31.12.2016',
      gkpz_years: '2016',
      customers: [customer.id]
    }
  end

  before(:each) { sign_in(user) }

  describe "GET options" do
    it "success" do
      get :options
      assert_response :success
    end
  end

  describe "GET show" do
    it "success" do
      get :show, params: { reports_other_lot_by_winner_flat: p, format: :xlsx }
      assert_response :success
    end
  end
end

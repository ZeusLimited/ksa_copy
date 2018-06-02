require 'spec_helper'

RSpec.describe Reports::Other::ExpectedEconomicEffectController, type: :controller do
  let(:user) { create(:user_user) }
  let(:customer) { create(:department) }

  let(:p) do
    {
      date_begin: '01.01.2014',
      date_end: '30.06.2015',
      gkpz_year: '2015',
      customers: [customer.id]
    }
  end

  before(:each) { sign_in(user) }

  describe "GET show" do
    it "success" do
      get :show, params: { reports_other_expected_economic_effect: p, format: :xlsx }
      assert_response :success
    end
  end
end

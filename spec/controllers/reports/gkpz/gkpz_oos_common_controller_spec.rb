require 'spec_helper'
require_relative '../shared_examples'

RSpec.describe Reports::Gkpz::GkpzOosCommonController, type: :controller do
  let(:user) { create(:user) }
  let(:report_class) { Reports::Gkpz::GkpzOosCommon }

  before(:each) { sign_in(user) }

  describe 'GET options' do
    it_should_behave_like 'report_options'
  end

  describe 'GET show' do
    let(:report) { report_class.name.underscore.tr('/', '_') }

    let(:valid_params) do
      { gkpz_year: Faker::Date.forward(23).year,
        date_gkpz_on_state:Faker::Date.forward(23),
        oos_etp: Constants::EtpAddress::EETP
      }
    end

    let(:fake) { instance_double(report_class, template: 'reports/gkpz/gkpz_oos_common/plan_oos_etp/main') }
    before { allow(report_class).to receive(:new).and_return(fake) }

    it 'call model method new' do      
      expect(report_class).to receive(:new).with(ActionController::Parameters)
      get :show, params: { format: :xlsx, reports_gkpz_gkpz_oos_common: valid_params }
    end

    it "assign variable @report before show template" do
      get :show, params: { format: :xlsx, reports_gkpz_gkpz_oos_common: valid_params }
      expect(assigns(:report)).to eq(fake)
    end

    it "render template main" do
      get :show, params: { format: :xlsx, reports_gkpz_gkpz_oos_common: valid_params }
      expect(response).to render_template(:main)
    end
  end
end

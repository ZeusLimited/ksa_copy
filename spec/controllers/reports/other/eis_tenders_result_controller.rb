require 'spec_helper'

RSpec.describe Reports::Other::EisTendersResultController, type: :controller do
  let(:user) { create(:user_user) }

  before(:each) { sign_in(user) }

  describe 'GET options' do
    it 'creates new instance of model' do
      allow(Reports::Other::EisTendersResult).to receive(:new)
      expect(Reports::Other::EisTendersResult).to receive(:new)
      get :options
    end
    it 'assigns variable @options' do
      fake_results = instance_double(Reports::Other::EisTendersResult)
      allow(Reports::Other::EisTendersResult).to receive(:new).and_return(fake_results)
      get :options
      expect(assigns(:options)).to eq(fake_results)
    end
    it 'render partial options' do
      allow(Reports::Other::EisTendersResult).to receive(:new)
      get :options
      expect(response).to render_template('reports/other/eis_tenders_result/options')
    end
  end

  describe 'GET show' do
    it 'create new instance of model' do
      allow(Reports::Other::EisTendersResult).to receive(:new)
      expect(Reports::Other::EisTendersResult).to receive(:new)
      get :show, params: { reports_other_eis_tenders_result: { format: :xlsx } }
    end
    it 'assigns variable @report' do
      fake_results = double(Reports::Other::EisTendersResult)
      allow(Reports::Other::EisTendersResult).to receive(:new).and_return(fake_results)
      get :show, params: { reports_other_eis_tenders_result: { format: :xlsx } }
      expect(assigns(:report)).to eq(fake_results)
    end
    it 'render partial main' do
      allow(Reports::Other::EisTendersResult).to receive(:new)
      get :show, params: { reports_other_eis_tenders_result: { format: :xlsx } }
      expect(response).to render_template('reports/other/eis_tenders_result/main')
    end
  end
end

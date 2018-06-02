require 'spec_helper'

shared_examples "report_options" do
  it 'call model method new' do
    expect(report_class).to receive(:new).with(Hash)
    get :options
  end

  it "assign variable @options before show template" do
    fake = instance_double(report_class)
    allow(report_class).to receive(:new).and_return(fake)
    get :options
    expect(assigns(:options)).to eq(fake)
  end

  it "render template options" do
    allow(report_class).to receive(:new)
    get :options
    expect(response).to render_template(:options)
  end
end

shared_examples "report_show" do |with_format|
    let(:report) { report_class.name.underscore.tr('/', '_') }

    it 'call model method new' do
      expect(report_class).to receive(:new).with(ActionController::Parameters)
      get :show, params: { format: :xlsx, "#{report}" => with_format }
    end

    it "assign variable @report before show template" do
      fake = instance_double(report_class)
      allow(report_class).to receive(:new).and_return(fake)
      get :show, params: { format: :xlsx, "#{report}" => with_format }
      expect(assigns(:report)).to eq(fake)
    end

    it "render template main" do
      allow(report_class).to receive(:new)
      get :show, params: { format: :xlsx, "#{report}" => with_format }
      expect(response).to render_template(:main)
    end
end

require 'spec_helper'

RSpec.describe FiasController, type: :controller do
  let(:user) { create(:user_user) }

  before(:each) { sign_in user }

  describe "POST create" do
    let(:valid_attributes) { attributes_for(:fias) }
    let(:fias) { create(:fias) }

    it "call model scope by_ids" do
      expect(Fias).to receive_message_chain(:by_ids, :take).with(fias.aoid_hex, fias.houseid_hex).with(no_args)
      post :create, params: { fias: { aoid_hex: fias.aoid_hex, houseid_hex: fias.houseid_hex } }
    end

    it "create fias object" do
      allow(Fias).to receive_message_chain(:by_ids, :take).and_return(nil)
      expect(Fias).to receive(:create).with(valid_attributes)
      post :create, params: { fias: valid_attributes }
    end

    it "render json fias object" do
      allow(Fias).to receive_message_chain(:by_ids, :take).and_return(fake_result = double(JSON))
      post :create, params: { fias: valid_attributes }
      expect(response.body).to eq(fake_result.to_json)
    end
  end

  describe "GET show" do
    let(:fake) { build(:fias) }
    let!(:fias) { FactoryGirl.create(:fias) }

    before(:each) { allow(Fias).to receive(:find).and_return(fake) }

    it "make object available in view" do
      get :show, params: { format: :json, id: fias.id }
      expect(assigns(:fias)).to eq(fake)
    end

    it "select template for rendering json" do
      get :show, params: { format: :json, id: fias.id }
      expect(response.body).to eq fake.to_json
    end
  end

end

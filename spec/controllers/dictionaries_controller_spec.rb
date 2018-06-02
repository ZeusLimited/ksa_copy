require 'spec_helper'

RSpec.describe DictionariesController, type: :controller do
  let(:user) { create(:user_user) }

  describe "User actions" do

    before(:each) { sign_in(user) }

    describe "order1352_reg_item" do
      let(:regulation_item) { double }

      it "get order1352 regulation item" do
        expect(Dictionary).to receive_message_chain(:order1352, :order1352_special)
          .with(no_args).with(regulation_item.to_s)
        get :order1352_reg_item, params: { format: :json, regulation_item: regulation_item }
      end
      it "render json" do
        fake_results = double
        allow(Dictionary).to receive_message_chain(:order1352, :order1352_special).and_return(fake_results)
        get :order1352_reg_item, params: { format: :json, regulation_item: regulation_item }
        expect(response.body).to eq(fake_results.to_json)
      end
    end
  end
end

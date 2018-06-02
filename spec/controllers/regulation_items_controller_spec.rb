require 'spec_helper'

RSpec.describe RegulationItemsController, type: :controller do
  let(:user) { create(:user_user) }
  let(:moderator) { create(:user_moderator) }
  let!(:regulation_item) { create(:regulation_item_with_tender_types) }

  let(:valid_attributes) { attributes_for(:regulation_item) }

  let(:invalid_attributes) { attributes_for(:regulation_item).merge(num: nil) }

  describe "User actions" do
    before(:each) { sign_in(user) }

    describe "GET index" do
      it "get all regulation items" do
        allow(RegulationItem).to receive_message_chain(:where, :order)
        get :index
        expect(response).to render_template(:index)
      end
      it "check calls method all and order" do
        expect(RegulationItem).to receive_message_chain(:where, :order).with(no_args).with(is_actual: :desc, num: :asc)
        get :index
      end
      it "check available result on view" do
        fake_results = double(RegulationItem)
        allow(RegulationItem).to receive_message_chain(:where, :order).and_return(fake_results)
        get :index
        expect(assigns(:regulation_items)).to eq(fake_results)
      end
    end

    describe "for_type method" do
      let(:root_cus_id) { double }

      it "get regulation_item for type" do
        expect(Department).to receive_message_chain(:find, :root_id, :to_i).and_return(root_cus_id)
        expect(RegulationItem).to receive_message_chain(:actuals, :dep_own_item, :for_type)
          .with(no_args).with(root_cus_id).with(Constants::TenderTypes::OOK.to_s)
        get :for_type, params: { format: :json, tender_type_id: Constants::TenderTypes::OOK, department_id: 2 }
      end
      it "render json" do
        fake_results = double
        expect(Department).to receive_message_chain(:find, :root_id, :to_i).and_return(root_cus_id)
        allow(RegulationItem).to receive_message_chain(:actuals, :dep_own_item, :for_type).and_return(fake_results)
        get :for_type, params: { format: :json, tender_type_id: Constants::TenderTypes::OOK, department_id: 2 }
        expect(response.body).to eq(fake_results.to_json)
      end
    end
  end

  describe "Moderators actions" do
    before(:each) { sign_in(moderator) }

    describe "POST create" do
      it "save element" do
        expect_any_instance_of(RegulationItem).to receive(:save)
        post :create, params: { regulation_item: attributes_for(:regulation_item) }
      end
      it "save equal true" do
        allow_any_instance_of(RegulationItem).to receive(:save).and_return(true)
        post :create, params: { regulation_item: attributes_for(:regulation_item) }
        expect(response).to redirect_to assigns(:index)
      end
      it "save equal false" do
        allow_any_instance_of(RegulationItem).to receive(:save).and_return(false)
        post :create, params: { regulation_item: attributes_for(:regulation_item) }
        expect(response).to render_template(:new)
      end
    end

    describe "PATCH update" do
      it "save element" do
        expect_any_instance_of(RegulationItem).to receive(:update)
        post :update, params: { id: regulation_item.to_param, regulation_item: valid_attributes }
      end
      it "update element equal true" do
        allow_any_instance_of(RegulationItem).to receive(:update).and_return(true)
        patch :update, params: { id: regulation_item.to_param, regulation_item: valid_attributes }
        expect(response).to redirect_to regulation_items_url
      end
      it "save equal false" do
        allow_any_instance_of(RegulationItem).to receive(:update).and_return(false)
        patch :update, params: { id: regulation_item.to_param, regulation_item: valid_attributes }
        expect(response).to render_template(:edit)
      end
    end

    describe "DELETE" do
      it "delete element" do
        expect_any_instance_of(RegulationItem).to receive(:destroy)
        delete :destroy, params: { id: regulation_item.to_param }
      end
      it "redirect to index" do
        allow_any_instance_of(RegulationItem).to receive(:update)
        delete :destroy, params: { id: regulation_item.to_param }
        expect(response).to redirect_to regulation_items_url
      end
    end
  end
end

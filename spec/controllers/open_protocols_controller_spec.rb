require 'spec_helper'

describe OpenProtocolsController do
  let(:user) { create(:user_user) }
  let(:commission) { create(:commission_with_users, :level1_kk) }
  let(:tender) { create(:tender_with_public_lot, :ook, department_id: commission.department_id) }
  let(:lot) { tender.lots[0] }

  let(:open_protocol) do
    create(:open_protocol, tender_id: tender.id, commission_id: commission.id)
  end

  let(:another_protocol) do
    create(:protocol,
           commission_id: zk.id,
           discuss_plan_lots_attributes: {
             "0" => {
               id: another_lot.id,
               status_id: another_lot.status_id,
               state: 'plan',
               tender_type_id: another_lot.tender_type_id
             }
           })
  end

  let(:valid_params) do
    {
      clerk_id: commission.commission_users.clerks[0].user_id,
      location: "SomeValue",
      num: "SomeValue",
      resolve: "SomeValue",
      sign_city: "SomeValue",
      sign_date: Date.current,
      commission_id: commission.id,
      compound_open_date_attributes: { date: Date.current, time: "10:00" },
      open_protocol_present_members_attributes: {
        "0" => {
          user_id: commission.commission_users[0].user_id,
          enable: "0",
          status_id: commission.commission_users[0].status
        },
        "1" => {
          user_id: commission.commission_users[1].user_id,
          enable: "1",
          status_id: commission.commission_users[1].status
        },
        "2" => {
          user_id: commission.commission_users[2].user_id,
          enable: "1",
          status_id: commission.commission_users[2].status
        },
        "3" => {
          user_id: commission.commission_users[3].user_id,
          enable: "0",
          status_id: commission.commission_users[3].status
        },
        "4" => {
          user_id: commission.commission_users[4].user_id,
          enable: "0",
          status_id: commission.commission_users[4].status
        }
      }
    }
  end

  let(:invalid_params) { valid_params.merge(num: "") }

  before(:each) do
    sign_in user
  end

  describe "GET show" do
    it "success" do
      get :show, params: { tender_id: tender.id, id: open_protocol.id }
      assert_response :success
    end
  end

  describe "GET new" do
    it "success" do
      get :new, params: { tender_id: tender.id }
      assert_response :success
    end
  end

  describe "POST create" do
    it "success" do
      assert_difference 'OpenProtocol.count' do
        post :create, params: { tender_id: tender.id, open_protocol: valid_params }
      end
      assert_redirected_to tender_open_protocol_url(tender, OpenProtocol.last)
    end

    it "fail" do
      assert_no_difference 'OpenProtocol.count' do
        post :create, params: { tender_id: tender.id, open_protocol: invalid_params }
      end

      assert_template :new
    end
  end

  describe "GET edit" do
    it "success" do
      get :edit, params: { tender_id: tender.id, id: open_protocol.id }
      assert_response :success
    end
  end

  describe "PATCH update" do
    it "success" do
      patch :update, params: { tender_id: tender.id, id: open_protocol.id, open_protocol: valid_params }
      assert_redirected_to tender_open_protocol_url(tender, open_protocol)
    end

    it "non valid" do
      patch :update, params: { tender_id: tender.id, id: open_protocol.id, open_protocol: invalid_params }
      assert_template :edit
    end
  end

  describe "DELETE destroy" do
    it "success" do
      open_protocol_id = open_protocol.id
      assert_difference('OpenProtocol.count', -1) do
        delete :destroy, params: { tender_id: tender.id, id: open_protocol_id }
      end

      assert_redirected_to tender_bidders_url(tender)
    end
  end

  describe "POST Present Memebers" do
    it "with open_protocol_id" do
      post :present_members, params: {
        tender_id: tender.id, commission_id: commission.id, open_protocol_id: open_protocol.id
      }
      assert_response :success
    end

    it "without open_protocol_id" do
      post :present_members, params: { tender_id: tender.id, commission_id: commission.id }
      assert_response :success
    end
  end
end

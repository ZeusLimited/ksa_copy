require 'spec_helper'

describe ProtocolsController do
  let(:user_boss) { create(:user_boss) }
  let(:user_moderator) { create(:user_moderator) }
  let(:plan_lot) { create(:plan_lot, :considered) }
  let(:another_lot) { create(:plan_lot, :considered) }
  let(:plan_lot_sd) { create(:plan_lot, :pre_confirm_sd) }
  let(:zk) { create(:commission, :level1_kk) }
  let(:czk) { create(:commission, :czk) }

  let(:protocol) do
    create(:protocol,
           commission_id: zk.id,
           discuss_plan_lots_attributes: {
             "0" => {
               id: plan_lot.id,
               status_id: plan_lot.status_id,
               state: 'plan',
               tender_type_id: plan_lot.tender_type_id
             }
           })
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
      protocol_type: 'zk',
      commission_id: zk.id,
      date_confirm: Date.current.to_s,
      format_id: Constants::FormatMeetings::FULL_TIME,
      location: "Хабаровск",
      num: "SomeValue",
      discuss_plan_lots_attributes: {
        "0" => {
          id: plan_lot.id,
          status_id: plan_lot.status_id,
          state: 'plan',
          tender_type_id: plan_lot.tender_type_id
        }
      }
    }
  end

  let(:valid_merge_params) do
    {
      gkpz_year: Date.current.year,
      protocol_type: 'zk',
      commission_id: zk.id,
      date_confirm: Date.current.to_s,
      format_id: Constants::FormatMeetings::FULL_TIME,
      location: "Хабаровск",
      num: "SomeValue",
      merge_ids: [
        protocol.id, another_protocol.id
      ]
    }
  end

  let(:invalid_params) { valid_params.merge(commission_id: czk.id) }
  let(:invalid_merge_params) { valid_merge_params.merge(num: "") }

  describe "USER_BOSS Actions" do
    before(:each) do
      sign_in user_boss
      user_boss.plan_lots << plan_lot
    end

    describe "GET index" do
      it "success" do
        get :index
        assert_response :success
      end
    end

    describe "GET new" do
      it "success zk" do
        get :new, params: { type: 'zk' }
        assert_response :success
      end

      it "success sd" do
        user_boss.plan_lots = [plan_lot_sd]
        get :new, params: { type: 'sd' }
        assert_response :success
      end
    end

    describe "POST create" do
      it "success" do
        assert_difference 'Protocol.count' do
          post :create, params: { protocol: valid_params }
        end
        assert_redirected_to plan_lots_url
      end

      it "fail" do
        assert_no_difference 'ReviewProtocol.count' do
          post :create, params: { protocol: invalid_params }
        end
        assert_template :new
      end
    end
  end

  describe "Moderator Actions" do
    before(:each) do
      sign_in user_moderator
    end

    describe "GET edit" do
      it "success" do
        protocol_id = protocol.id
        get :edit, params: { id: protocol_id }
        assert_response :success
      end
    end

    describe "PATCH update" do
      it "success" do
        patch :update, params: { id: protocol.id, protocol: valid_params }
        assert_redirected_to protocol_url(protocol)
      end

      it "non valid" do
        patch :update, params: { id: protocol.id, protocol: invalid_params }
        assert_template :edit
      end
    end

    describe "DELETE destroy" do
      it "success" do
        protocol_id = protocol.id
        assert_difference('Protocol.count', -1) do
          delete :destroy, params: { id: protocol_id }
        end

        assert_redirected_to protocols_url
      end
    end

    describe "GET merge_new" do
      it "success" do
        get :merge_new, params: { pids: [protocol.id, another_protocol.id].map(&:to_s) }
        assert_response :success
      end
    end

    describe "POST merge_create" do
      it "success" do
        assert_difference 'Protocol.count' do
          post :merge_create, params: { protocol: valid_merge_params }
        end
        assert_redirected_to protocol_url(Protocol.last)
      end

      it "fail" do
        protocol.id
        another_protocol.id
        assert_no_difference 'Protocol.count' do
          post :merge_create, params: { protocol: invalid_merge_params }
        end

        assert_template :merge_new
      end
    end
  end
end

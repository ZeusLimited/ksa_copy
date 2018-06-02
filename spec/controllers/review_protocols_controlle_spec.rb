require 'spec_helper'

RSpec.describe ReviewProtocolsController, type: :controller do
  let(:user) { create(:user_user) }
  let(:user_boss) { create(:user_boss) }
  let(:tender) { create(:tender_with_open_lot, :ook) }
  let(:lot) { tender.lots[0] }

  let(:tender_rc) { create(:tender_with_review_confirm_lot) }
  let(:review_protocol) do
    create(:review_protocol,
           tender_id: tender.id,
           review_lots_attributes: [{ "lot_id" => lot.id.to_s, "enable" => "1", "rebid" => false }],
           confirm_date: tender.open_protocol_sign_date + 3.days)
  end

  let(:valid_params) do
    {
      num: "#{tender.num}-Р",
      confirm_date: tender.open_protocol_sign_date + 3.days,
      review_lots_attributes: {
        "0" => {
          enable: "1",
          lot_id: lot.id,
          rebid: "true",
          compound_rebid_date_attributes: { date: tender.open_protocol_sign_date + 4.days, time: "10:00" },
          rebid_place: "г. Хабаровск"
        }
      }
    }
  end

  let(:valid_params_without_rebid) do
    {
      num: "#{tender.num}-Р",
      confirm_date: tender.open_protocol_sign_date + 3.days,
      review_lots_attributes: {
        "0" => {
          enable: "1",
          lot_id: lot.id,
          rebid: "false",
          compound_rebid_date_attributes: { date: tender.open_protocol_sign_date + 4.days, time: "10:00" },
          rebid_place: "г. Хабаровск"
        }
      }
    }
  end
  let(:update_valid_params) do
    vp = valid_params
    vp[:review_lots_attributes]["0"].merge!(review_protocol_id: review_protocol.id)
    vp
  end

  let(:invalid_params) { valid_params.merge(num: '') }

  describe "USER actions" do
    before(:each) do
      sign_in(user)
    end

    describe "GET new" do
      it "success" do
        get :new, params: { tender_id: tender.id }
        assert_response :success
      end
    end

    describe "POST create" do
      it "success" do
        assert_difference 'ReviewProtocol.count' do
          post :create, params: { tender_id: tender.id, review_protocol: valid_params }
        end

        assert_redirected_to tender_review_protocol_url(tender, ReviewProtocol.last)
      end

      it "success without rebid" do
        assert_difference 'ReviewProtocol.count' do
          post :create, params: { tender_id: tender.id, review_protocol: valid_params_without_rebid }
        end

        assert_redirected_to tender_review_protocol_url(tender, ReviewProtocol.last)
      end

      it "non valid" do
        assert_no_difference 'ReviewProtocol.count' do
          post :create, params: { tender_id: tender.id, review_protocol: invalid_params }
        end
        assert_template :new
      end
    end

    describe "GET edit" do
      it "success" do
        get :edit, params: { tender_id: tender.id, id: review_protocol.id }
        assert_response :success
      end
    end

    describe "PATCH update" do
      it "success" do
        patch :update, params: { tender_id: tender.id, id: review_protocol.id, review_protocol: update_valid_params }
        assert_redirected_to tender_review_protocol_url(tender, review_protocol)
      end

      it "non valid" do
        patch :update, params: { tender_id: tender.id, id: review_protocol.id, review_protocol: invalid_params }
        assert_template :edit
      end
    end

    describe "DELETE destroy" do
      it "success" do
        review_protocol_id = review_protocol.id
        assert_difference('ReviewProtocol.count', -1) do
          delete :destroy, params: { tender_id: tender.id, id: review_protocol_id }
        end

        assert_redirected_to tender_review_protocols_url(tender)
      end
    end

    describe "PATCH pre_confirm" do
      it "success" do
        review_protocol_id = review_protocol.id
        patch :pre_confirm, params: { tender_id: tender.id, id: review_protocol_id }
        assert_redirected_to tender_review_protocol_url(tender, review_protocol)
      end
    end

    describe "patch update_confirm_date" do
      it "success" do
        review_protocol_id = tender_rc.review_protocols[0].id
        patch :update_confirm_date, params: {
          tender_id: tender_rc.id, id: review_protocol_id, confirm_date: "2014-06-02"
        }
        assert_response :success
      end

      it "fail" do
        review_protocol_id = tender_rc.review_protocols[0].id
        patch :update_confirm_date, params: {
          tender_id: tender_rc.id, id: review_protocol_id, confirm_date: "2015-02-08"
        }
        assert_template :update_confirm_date
      end
    end
  end

  describe "USER_BOSS actions" do
    before(:each) do
      sign_in(user_boss)
    end

    let(:tender_r) { create(:tender_with_review_lot) }

    describe "PATCH confirm" do
      it "success" do
        review_protocol_id = tender_r.review_protocols[0].id
        patch :confirm, params: { tender_id: tender_r.id, id: review_protocol_id }
        assert_redirected_to tender_review_protocol_url(tender_r, review_protocol_id)
      end
    end

    describe "PATCH revoke_confirm" do
      it "success" do
        review_protocol_id = tender_rc.review_protocols[0].id
        patch :revoke_confirm, params: { tender_id: tender_rc.id, id: review_protocol_id }
        assert_redirected_to tender_review_protocol_url(tender_rc, review_protocol_id)
      end
    end

    describe "PATCH cancel_confirm" do
      it "success" do
        review_protocol_id = tender_r.review_protocols[0].id
        patch :cancel_confirm, params: { tender_id: tender_r.id, id: review_protocol_id }
        assert_redirected_to tender_review_protocol_url(tender_r, review_protocol_id)
      end
    end
  end
end

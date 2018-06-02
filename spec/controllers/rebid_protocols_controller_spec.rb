require 'spec_helper'

RSpec.describe RebidProtocolsController, type: :controller do
  let(:user) { create(:user_user) }
  let(:tender) { create(:tender_with_review_confirm_lot, :ook) }
  let(:commission) { create(:commission_with_users, :level1_kk) }
  let(:lot) { tender.lots[0] }

  let(:rebid_protocol) do
    create(:rebid_protocol,
           tender_id: tender.id,
           rebid_lots: [{ "id" => lot.id.to_s, "selected" => "1" }],
           rebid_date: lot.review_lots[0].rebid_date,
           confirm_date: lot.review_lots[0].rebid_date + 3.days)
  end

  let(:valid_params) do
    {
      tender_id: tender.id,
      num: "РАО/Ц-76/ОК-П",
      confirm_date: "20.07.2015",
      confirm_city: "г. Хабаровск, ул. Ленинградская, д.46",
      rebid_lots_attributes: {
        "0" => {
          selected: "1",
          id: lot.id
        }
      },
      commission_id: commission.id,
      rebid_protocol_present_members_attributes: {
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
      },
      compound_rebid_date_attributes: {
        date: lot.review_lots[0].rebid_date.strftime('%d.%m.%Y'),
        time: lot.review_lots[0].rebid_date.strftime('%H:%M')
      },
      location: "Электронная торговая площадка",
      resolve: "Утвердить протокол заседания Постоянно действующей закупочной комиссии",
      clerk_id: commission.commission_users.clerks[0].user_id
    }
  end

  before(:each) do
    sign_in(user)
  end

  let(:invalid_params) { valid_params.merge(num: '') }

  describe "GET new" do
    it "success" do
      get :new, params: { tender_id: tender.id }
      assert_response :success
    end
  end

  describe "POST create" do
    it "success" do
      assert_difference 'RebidProtocol.count' do
        post :create, params: { tender_id: tender.id, rebid_protocol: valid_params }
      end

      assert_redirected_to tender_rebid_protocols_url(tender)
    end

    it "non valid" do
      assert_no_difference 'RebidProtocol.count' do
        post :create, params: { tender_id: tender.id, rebid_protocol: invalid_params }
      end

      assert_template :new
    end
  end

  describe "GET edit" do
    it "success" do
      get :edit, params: { tender_id: tender.id, id: rebid_protocol.id }
      assert_response :success
    end
  end

  describe "PATCH update" do
    it "success" do
      patch :update, params: { tender_id: tender.id, id: rebid_protocol.id, rebid_protocol: valid_params }
      assert_redirected_to tender_rebid_protocols_url(tender)
    end

    it "non valid" do
      patch :update, params: { tender_id: tender.id, id: rebid_protocol.id, rebid_protocol: invalid_params }
      assert_template :edit
    end
  end

  describe "DELETE destroy" do
    it "success" do
      rebid_protocol_id = rebid_protocol.id
      assert_difference('RebidProtocol.count', -1) do
        delete :destroy, params: { tender_id: tender.id, id: rebid_protocol_id }
      end

      assert_redirected_to tender_rebid_protocols_url(tender)
    end
  end

  describe "POST present_members" do
    it "success with rebid_protocol_id" do
      post :present_members, params: {
        tender_id: tender.id, rebid_protocol_id: rebid_protocol.id, commission_id: commission.id
      }
    end

    it "success without rebid_protocol_id" do
      post :present_members, params: { tender_id: tender.id, commission_id: commission.id }
    end
  end
end

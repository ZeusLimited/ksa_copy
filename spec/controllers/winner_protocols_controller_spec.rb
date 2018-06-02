require 'spec_helper'
include Constants

describe WinnerProtocolsController do
  let(:tender) { create(:tender, :ook, lots: build_list(:lot_with_spec, 4, :public)) }

  let(:tender_for_confirm) { create(:tender, :ook, lots: build_list(:lot_with_spec, 4, :sw)) }
  let(:tender_for_revoke_confirm) { create(:tender, :ook, lots: build_list(:lot_with_spec, 4, :sw_confirm)) }
  let(:tender_for_sign) { create(:tender, :ook, lots: build_list(:lot_with_spec, 4, :sw_confirm)) }
  let(:tender_for_cancel_confirm) do
    create :tender,
           :ook,
           open_protocol: build(:open_protocol),
           lots: build_list(:lot_with_spec, 4, :sw)
  end
  let(:tender_for_revoke_sign) do
    create(:tender,
           :ook,
           lots: [build(:lot_with_spec, :winner),
                  build(:lot_with_spec, :winner),
                  build(:lot_with_spec, :fail),
                  build(:lot_with_spec, :cancel)])
  end

  let(:wp_attrs) do
    attributes_for(:winner_protocol).merge(
      tender_id: tender.id,
      winner_protocol_lots_attributes: {
        "0" => { lot_id: tender.lots[0].id, enable: "1", solution_type_id: WinnerProtocolSolutionTypes::WINNER },
        "1" => { lot_id: tender.lots[1].id, enable: "1", solution_type_id: WinnerProtocolSolutionTypes::SINGLE_SOURCE },
        "2" => { lot_id: tender.lots[2].id, enable: "1", solution_type_id: WinnerProtocolSolutionTypes::FAIL },
        "3" => { lot_id: tender.lots[3].id, enable: "1", solution_type_id: WinnerProtocolSolutionTypes::CANCEL }
      }
    )
  end

  let(:wp_for_confirm_attrs) do
    attributes_for(:winner_protocol).merge(
      tender_id: tender_for_confirm.id,
      winner_protocol_lots_attributes: [
        { lot_id: tender_for_confirm.lots[0].id, enable: "1", solution_type_id: WinnerProtocolSolutionTypes::WINNER },
        { lot_id: tender_for_confirm.lots[1].id, enable: "1", solution_type_id: WinnerProtocolSolutionTypes::SINGLE_SOURCE },
        { lot_id: tender_for_confirm.lots[2].id, enable: "1", solution_type_id: WinnerProtocolSolutionTypes::FAIL },
        { lot_id: tender_for_confirm.lots[3].id, enable: "1", solution_type_id: WinnerProtocolSolutionTypes::CANCEL }
      ]
    )
  end

  let(:wp_for_cancel_confirm_attrs) do
    attributes_for(:winner_protocol).merge(
      tender_id: tender_for_cancel_confirm.id,
      winner_protocol_lots_attributes: [
        { lot_id: tender_for_cancel_confirm.lots[0].id, enable: "1", solution_type_id: WinnerProtocolSolutionTypes::WINNER },
        { lot_id: tender_for_cancel_confirm.lots[1].id, enable: "1", solution_type_id: WinnerProtocolSolutionTypes::SINGLE_SOURCE },
        { lot_id: tender_for_cancel_confirm.lots[2].id, enable: "1", solution_type_id: WinnerProtocolSolutionTypes::FAIL },
        { lot_id: tender_for_cancel_confirm.lots[3].id, enable: "1", solution_type_id: WinnerProtocolSolutionTypes::CANCEL }
      ]
    )
  end

  let(:wp_for_revoke_confirm_attrs) do
    attributes_for(:winner_protocol).merge(
      tender_id: tender_for_revoke_confirm.id,
      winner_protocol_lots_attributes: [
        { lot_id: tender_for_revoke_confirm.lots[0].id, enable: "1", solution_type_id: WinnerProtocolSolutionTypes::WINNER },
        { lot_id: tender_for_revoke_confirm.lots[1].id, enable: "1", solution_type_id: WinnerProtocolSolutionTypes::SINGLE_SOURCE },
        { lot_id: tender_for_revoke_confirm.lots[2].id, enable: "1", solution_type_id: WinnerProtocolSolutionTypes::FAIL },
        { lot_id: tender_for_revoke_confirm.lots[3].id, enable: "1", solution_type_id: WinnerProtocolSolutionTypes::CANCEL }
      ]
    )
  end

  let(:wp_for_sign_attrs) do
    attributes_for(:winner_protocol).merge(
      tender_id: tender_for_sign.id,
      winner_protocol_lots_attributes: [
        { lot_id: tender_for_sign.lots[0].id, enable: "1", solution_type_id: WinnerProtocolSolutionTypes::WINNER },
        { lot_id: tender_for_sign.lots[1].id, enable: "1", solution_type_id: WinnerProtocolSolutionTypes::SINGLE_SOURCE },
        { lot_id: tender_for_sign.lots[2].id, enable: "1", solution_type_id: WinnerProtocolSolutionTypes::FAIL },
        { lot_id: tender_for_sign.lots[3].id, enable: "1", solution_type_id: WinnerProtocolSolutionTypes::CANCEL }
      ]
    )
  end

  let(:wp_for_revoke_sign_attrs) do
    attributes_for(:winner_protocol).merge(
      tender_id: tender_for_revoke_sign.id,
      winner_protocol_lots_attributes: [
        { lot_id: tender_for_revoke_sign.lots[0].id, enable: "1", solution_type_id: WinnerProtocolSolutionTypes::WINNER },
        { lot_id: tender_for_revoke_sign.lots[1].id, enable: "1", solution_type_id: WinnerProtocolSolutionTypes::SINGLE_SOURCE },
        { lot_id: tender_for_revoke_sign.lots[2].id, enable: "1", solution_type_id: WinnerProtocolSolutionTypes::FAIL },
        { lot_id: tender_for_revoke_sign.lots[3].id, enable: "1", solution_type_id: WinnerProtocolSolutionTypes::CANCEL }
      ]
    )
  end

  before(:each) do
    @user = create(:user_boss)
    sign_in @user
  end

  describe "GET new" do
    it "good render new" do
      get :new, params: { tender_id: tender.id }
      expect(response).to be_success
      winner_protocol = assigns(:winner_protocol)
      expect(winner_protocol).to be_a_new(WinnerProtocol)
      expect(winner_protocol.num).to eq("#{tender.num}-ВП")
    end
  end

  describe "POST create" do
    it "success" do
      expect do
        post :create, params: { tender_id: tender.id, winner_protocol: wp_attrs }
      end.to change(WinnerProtocol, :count).by(1)
      wp = assigns(:winner_protocol)
      expect(wp).to be_a(WinnerProtocol)
      expect(wp).to be_persisted
      expect(response).to be_redirect
    end

    it "fail" do
      post :create, params: { tender_id: tender.id, winner_protocol: wp_attrs.merge(confirm_date: nil) }
      expect(assigns(:winner_protocol)).to be_a_new(WinnerProtocol)
      expect(response).to render_template("new")
    end
  end

  describe "PATCH update" do
    it "success" do
      wp = WinnerProtocol.create! wp_attrs
      patch :update, params: { tender_id: tender.id, id: wp.to_param, winner_protocol: wp_attrs.merge(num: "123") }
      winner_protocol = assigns(:winner_protocol)
      expect(winner_protocol.num).to eq("123")
      expect(winner_protocol).to be_persisted
      expect(response).to be_redirect
    end

    it "fail" do
      wp = WinnerProtocol.create! wp_attrs
      patch :update, params: { tender_id: tender.id, id: wp.to_param, winner_protocol: wp_attrs.merge(num: nil) }
      winner_protocol = assigns(:winner_protocol)
      expect(winner_protocol).to eq(wp)
      expect(response).to render_template("edit")
    end
  end

  describe "DELETE destroy" do
    it "success" do
      wp = WinnerProtocol.create! wp_attrs
      expect do
        delete :destroy, params: { tender_id: tender.id, id: wp.to_param }
      end.to change(WinnerProtocol, :count).by(-1)
      expect(response).to redirect_to(tender_winner_protocols_url(tender))
    end
  end

  describe "patch pre_confirm" do
    it "success" do
      wp = WinnerProtocol.create! wp_attrs
      patch :pre_confirm, params: { tender_id: tender.id, id: wp.to_param }
      expect(wp.lots[0].status_id).to eq(LotStatus::SW)
    end
  end

  describe "patch cancel_confirm" do
    it "success" do
      wp = WinnerProtocol.create! wp_for_cancel_confirm_attrs
      patch :cancel_confirm, params: { tender_id: tender_for_cancel_confirm.id, id: wp.to_param }
      expect(wp.lots).to all(have_attributes(status_id: LotStatus::OPEN))
      expect(response).to redirect_to(tender_winner_protocol_url(tender_for_cancel_confirm, wp.to_param))
    end
  end

  describe "patch confirm" do
    it "success" do
      wp = WinnerProtocol.create! wp_for_confirm_attrs
      patch :confirm, params: { tender_id: tender_for_confirm.id, id: wp.to_param }
      expect(wp.lots).to all(have_attributes(status_id: LotStatus::SW_CONFIRM))
      expect(response).to redirect_to(tender_winner_protocol_url(tender_for_confirm, wp.to_param))
    end
  end

  describe "patch revoke_confirm" do
    it "success" do
      wp = WinnerProtocol.create! wp_for_revoke_confirm_attrs
      patch :revoke_confirm, params: { tender_id: tender_for_revoke_confirm.id, id: wp.to_param }
      expect(wp.lots).to all(have_attributes(status_id: LotStatus::SW))
      expect(response).to redirect_to(tender_winner_protocol_url(tender_for_revoke_confirm, wp.to_param))
    end
  end

  describe "patch sign" do
    it "success" do
      wp = WinnerProtocol.create! wp_for_sign_attrs
      patch :sign, params: { tender_id: tender_for_sign.id, id: wp.to_param }
      expect(wp.lots.map(&:status_id)).to contain_exactly(
        LotStatus::WINNER, LotStatus::WINNER, LotStatus::FAIL, LotStatus::CANCEL
      )
      expect(response).to redirect_to(tender_winner_protocol_url(tender_for_sign, wp.to_param))
    end
  end

  describe "patch revoke_sign" do
    it "success" do
      wp = WinnerProtocol.create! wp_for_revoke_sign_attrs
      patch :revoke_sign, params: { tender_id: tender_for_revoke_sign.id, id: wp.to_param }
      expect(wp.lots).to all(have_attributes(status_id: LotStatus::SW_CONFIRM))
      expect(response).to redirect_to(tender_winner_protocol_url(tender_for_revoke_sign, wp.to_param))
    end
  end

  describe "patch update_confirm_date" do
    it "success" do
      wp = WinnerProtocol.create! wp_for_sign_attrs
      patch :update_confirm_date, params: {
        tender_id: tender_for_sign.id, id: wp.to_param, confirm_date: Date.new(2016, 2, 8)
      }
      assert_response :success
    end

    it "fail" do
      wp = WinnerProtocol.create! wp_for_sign_attrs
      patch :update_confirm_date, params: {
        tender_id: tender_for_sign.id, id: wp.to_param, confirm_date: "2015-02-08"
      }
      assert_template :update_confirm_date
    end
  end
end

require 'spec_helper'
include Constants

describe ResultProtocolsController do
  let(:lot1) { create(:lot_with_spec, :winner) }
  let(:lot2) { create(:lot_with_spec, :fail) }
  let(:lot3) { create(:lot_with_spec, :winner) }
  let(:tender) { create(:tender, :ook, lots: [lot1, lot2, lot3]) }
  let(:ozp) { create(:tender, :ozp, lots: [lot1, lot2, lot3]) }

  let(:rp_attrs) do
    attributes_for(:result_protocol).merge(
      tender_id: tender.id,
      result_protocol_lots_attributes: { "0" => { lot_id: lot1.id, enable: "1" } }
    )
  end

  before(:each) do
    @user = create(:user_user)
    sign_in @user
    create(:winner_protocol,
           tender: tender,
           winner_protocol_lots: [build(:winner_protocol_lot, :winner, lot: lot1),
                                  build(:winner_protocol_lot, :fail, lot: lot2),
                                  build(:winner_protocol_lot, :single_source, lot: lot3)])
  end

  describe "GET new" do
    it "good render new" do
      get :new, params: { tender_id: tender.id }
      expect(response).to be_success
      result_protocol = assigns(:result_protocol)
      expect(result_protocol).to be_a_new(ResultProtocol)
      expect(result_protocol.num).to eq("#{tender.num}-И")
    end

    it "bad render new" do
      get :new, params: { tender_id: ozp.id }
      expect(response).to be_redirect
    end
  end

  describe "POST create" do
    it "success" do
      expect do
        post :create, params: { tender_id: tender.id, result_protocol: rp_attrs }
      end.to change(ResultProtocol, :count).by(1)
      rp = assigns(:result_protocol)
      expect(rp).to be_a(ResultProtocol)
      expect(rp).to be_persisted
      expect(response).to be_redirect
    end

    it "fail" do
      post :create, params: { tender_id: tender.id, result_protocol: rp_attrs.merge(sign_city: nil) }
      expect(assigns(:result_protocol)).to be_a_new(ResultProtocol)
      expect(response).to render_template("new")
    end
  end

  describe "PATCH update" do
    it "success" do
      rp = ResultProtocol.create! rp_attrs
      patch :update, params: { tender_id: tender.id, id: rp.to_param, result_protocol: rp_attrs.merge(num: "123") }
      result_protocol = assigns(:result_protocol)
      expect(result_protocol.num).to eq("123")
      expect(result_protocol).to be_persisted
      expect(response).to be_redirect
    end

    it "fail" do
      rp = ResultProtocol.create! rp_attrs
      patch :update, params: { tender_id: tender.id, id: rp.to_param, result_protocol: rp_attrs.merge(num: nil) }
      result_protocol = assigns(:result_protocol)
      expect(result_protocol).to eq(rp)
      expect(response).to render_template("edit")
    end
  end

  describe "DELETE destroy" do
    it "success" do
      rp = ResultProtocol.create! rp_attrs
      expect do
        delete :destroy, params: { tender_id: tender.id, id: rp.to_param }
      end.to change(ResultProtocol, :count).by(-1)
      expect(response).to redirect_to(tender_result_protocols_url(tender))
    end
  end

  describe "patch sign" do
    it "success" do
      rp = ResultProtocol.create! rp_attrs
      patch :sign, params: { tender_id: tender.id, id: rp.to_param }
      expect(rp.lots.first.status_id).to eq(LotStatus::RP_SIGN)
      expect(response).to redirect_to(tender_result_protocol_url(tender, rp.to_param))
    end
  end

  describe "patch revoke_sign" do
    it "success" do
      lot1.update_attribute(:status_id, LotStatus::RP_SIGN)
      rp = ResultProtocol.create! rp_attrs
      patch :revoke_sign, params: { tender_id: tender.id, id: rp.to_param }
      expect(rp.lots.first.status_id).to eq(LotStatus::WINNER)
      expect(response).to redirect_to(tender_result_protocol_url(tender, rp.to_param))
    end
  end
end

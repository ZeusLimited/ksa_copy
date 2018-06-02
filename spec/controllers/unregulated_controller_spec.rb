require 'spec_helper'

RSpec.describe UnregulatedController, type: :controller do
  let(:user) { create(:user_user) }

  let(:plan_lot) { create(:plan_lot_with_approved_order_and_specs, :agreement) }
  let(:plan_specification) { PlanSpecification.where(plan_lot: plan_lot).first }
  let(:contractor) { create(:contractor) }

  let(:tables_expressions) do
    [
      'Tender.count',
      'Lot.count',
      'Specification.count',
      'OpenProtocol.count',
      'WinnerProtocol.count',
      'WinnerProtocolLot.count',
      'Bidder.count',
      'Offer.count',
      'OfferSpecification.count',
      'Contract.count',
      'ContractSpecification.count',
      'ContractAmount.count'
    ]
  end

  let(:tender_contract) { create(:tender_with_contract_lot, :unregulated) }
  let(:lot) { tender_contract.lots[0] }
  let(:bidder) { tender_contract.bidders[0] }
  let(:offer) { tender_contract.bidders[0].offers[0] }
  let(:offer_specification) { tender_contract.bidders[0].offers[0].offer_specifications[0] }
  let(:contract) { tender_contract.bidders[0].offers[0].contract }

  let(:valid_params) do
    {
      what_valid: "form",
      num: "90031",
      department_id: "4",
      user_id: user.id,
      announce_date: Date.current + 1,
      name: "Оценка транспорта для целей страхования",
      lots_attributes: [
        {
          plan_lot_id: plan_lot.id,
          plan_lot_guid: plan_lot.guid,
          num: "1",
          non_public_reason: "aaa",
          note: "bbb"
        }
      ],
      bidders_attributes: [
        {
          contractor_id: contractor.id,
          offers_attributes: [
            {
              plan_lot_id: plan_lot.id,
              status_id: OfferStatuses::WIN,
              offer_specifications_attributes: [
                {
                  financing_id: plan_specification.financing_id,
                  plan_specification_id: plan_specification.id,
                  final_cost_money: "200 000.00",
                  final_cost_nds_money: "230 000.00"
                }
              ],
              contract_attributes: {
                _destroy: "0",
                num: "333",
                confirm_date: Date.current + 1,
                delivery_date_begin: Date.current + 2,
                delivery_date_end: Date.current + 3,
                non_delivery_reason: "ccc"
              },
              non_contract_reason: "ddd",
              _destroy: "false"
            }
          ],
          _destroy: "false"
        }
      ]
    }
  end

  let(:invalid_params) { valid_params.merge(num: '') }

  let(:update_valid_params) do
    vp = valid_params
    vp[:lots_attributes][0].merge!(id: lot.id)
    vp[:bidders_attributes][0].merge!(id: bidder.id)
    offer_attrs = vp[:bidders_attributes][0][:offers_attributes][0]
    offer_attrs.merge!(id: offer.id)
    offer_attrs[:offer_specifications_attributes][0].merge!(id: offer_specification.id)
    offer_attrs[:contract_attributes].merge!(id: contract.id)
    vp
  end

  let(:update_invalid_params) { update_valid_params.merge(num: '') }

  before(:each) do
    sign_in(user)
    user.plan_lots << plan_lot
  end

  describe "GET new" do
    it "success" do
      get :new
      assert_response :success
    end

    it "fail" do
      user.plan_lots.delete_all
      get :new
      assert_response :redirect
    end
  end

  describe "POST create" do
    it "success" do
      _pl = plan_lot
      assert_difference tables_expressions do
        post :create, params: { tender: valid_params }
      end

      assert_redirected_to tender_url(Tender.last)
    end

    it "non valid" do
      _pl = plan_lot
      assert_no_difference tables_expressions do
        post :create, params: { tender: invalid_params }
      end

      assert_template :new
    end
  end

  describe "GET edit" do
    it "success" do
      get :edit, params: { id: tender_contract.id }
      assert_response :success
    end
  end

  describe "PATCH update" do
    it "success" do
      patch :update, params: { id: tender_contract.id, tender: update_valid_params }
      assert_redirected_to tender_url(tender_contract)
    end

    it "non valid" do
      patch :update, params: { id: tender_contract.id, tender: update_invalid_params }
      assert_template :edit
    end
  end
end

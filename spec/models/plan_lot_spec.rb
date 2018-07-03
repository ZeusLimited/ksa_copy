# frozen_string_literal: true

require 'spec_helper'
require 'awesome_print'

RSpec.describe PlanLot, type: :model do
  include_examples 'tender types'

  describe 'observers#manage_eis_num' do
    let(:plan_lot) { create(:plan_lot) }

    it { expect { plan_lot }.to change { EisPlanLot.count }.by(1) }

    context 'eis' do
      before { plan_lot }

      subject(:eis) { EisPlanLot.last }

      it { expect(eis.plan_lot_guid).to eq plan_lot.guid }
      it { expect(eis.year).to eq plan_lot.announce_date.year }
      it { expect(eis.num).to eq plan_lot.id.to_s }
    end
  end

  describe 'observers#destroy_eis_num' do
    let!(:plan_lot) { create(:plan_lot) }

    it { expect { plan_lot.destroy }.to change { EisPlanLot.count }.by(-1) }

    context 'two versions' do
      let(:year) { 2018 }
      let(:plan_lot_v1) { create(:plan_lot, version: 1, gkpz_year: year, announce_date: Time.new(year, 12, 1)) }
      let!(:plan_lot) do
        create(:plan_lot, guid: plan_lot_v1.guid, gkpz_year: year, announce_date: Time.new(year, 2, 1))
      end

      it { expect { plan_lot.destroy }.not_to change { EisPlanLot.count } }
    end
  end

  describe '#validate_okdp_etp' do
    subject { plan_lot.errors[:etp_address_id] }

    let(:plan_lot) { build(:plan_lot_with_specs, tender_type_id: tender_type_id, plan_specifications: [plan_specification]) }
    let(:plan_specification) { build(:plan_specification) }
    let(:error_message) { SpecError.model_message(:plan_lot, :etp_address_id, :order616) }

    before do
      create(:okdp_sme_etp, code: plan_specification.okdp_code, okdp_type: Constants::OkdpSmeEtpType::ETP)
      plan_lot.valid?
    end

    context 'when tender type exclude 616' do
      let(:tender_type_id) { Constants::TenderTypes::ORDER616_EXCLUSION.sample }

      it { is_expected.not_to include error_message }
    end

    context 'when tender type include 616' do
      let(:tender_type_id) { (Constants::TenderTypes::ALL - Constants::TenderTypes::ORDER616_EXCLUSION).sample }

      it { is_expected.to include error_message }
    end
  end

  context '#valid_sme_costs' do
    let(:error_message) { "не может иметь значение МСП, т.к. закупка более 400 млн. руб. без НДС" }
    let(:plan_lot) { build(:plan_lot, :sme, plan_specifications: [build(:plan_specification, :cost_100, :cost_nds_100)]) }

    before do
      allow(Setting).to receive(:company).exactly(11).times.and_return('raoesv')
      plan_lot.valid?
    end

    context 'sum more 100 mln' do
      let(:plan_lot) { build(:plan_lot, :sme, plan_specifications: [build(:plan_specification, :cost_100, :cost_nds_100)]) }
      it do
        expect(plan_lot.errors.messages[:sme_type_id]).not_to include(error_message)
      end
    end
    context 'sum more 400 mln' do
      let(:plan_lot) { build(:plan_lot, :sme, plan_specifications: [build(:plan_specification, cost: 500_000_000, cost_nds: 500_000_000)]) }
      it { expect(plan_lot.errors.messages[:sme_type_id]).to include(error_message) }
    end
  end

  context "#contract?" do
    let(:plan_lot) { create(:plan_lot) }
    let(:tender_contract) { create(:tender_with_contract_lot) }
    let(:plan_lot_with_contract) { tender_contract.lots[0].plan_lot }

    describe '#valid_szk' do
      subject { plan_lot.valid? }
      let(:error_message) { "должна быть «СЗК», т.к. заказчик не является организатором" }
      context 'unregulated?' do
        let!(:plan_lot) { build(:plan_lot, :unregulated, plan_specifications: [build(:plan_specification)]) }
        it do
          plan_lot.valid?
          expect(plan_lot.errors.messages[:commission_id]).not_to include(error_message)
        end
      end
      context 'single source?' do
        let!(:plan_lot) { build(:plan_lot, :single_source, plan_specifications: [build(:plan_specification)]) }
        it do
          plan_lot.valid?
          expect(plan_lot.errors.messages[:commission_id]).not_to include(error_message)
        end
      end
      context 'department_id is nil' do
        let!(:plan_lot) { build(:plan_lot, department_id: nil, plan_specifications: [build(:plan_specification)]) }
        it do
          plan_lot.valid?
          expect(plan_lot.errors.messages[:commission_id]).not_to include(error_message)
        end
      end
      context 'commission is not for foreign customers' do
        let!(:plan_lot) { build(:plan_lot, plan_specifications: [build(:plan_specification)]) }
        it do
          allow(plan_lot).to receive_message_chain(:commission, :for_customers?).and_return(false)
          plan_lot.valid?
          expect(plan_lot.errors.messages[:commission_id]).to include(error_message)
        end
      end
      context 'commission is not set' do
        let!(:plan_lot) { build(:plan_lot, plan_specifications: [build(:plan_specification)]) }
        it do
          allow(plan_lot).to receive(:commission).and_return(nil)
          plan_lot.valid?
          expect(plan_lot.errors.messages[:commission_id]).not_to include(error_message)
        end
      end
    end

    describe '#valid_etp_address' do
      before { plan_lot.valid? }

      describe 'not etp' do
        let(:error_message) { "должен быть вне ЭТП" }

        context 'etp_address is b2b' do
          context 'when in list' do
            let!(:plan_lot) { build(:plan_lot, :etp_b2b, tender_type_id: Constants::TenderTypes::NON_ETP.sample) }

            it { expect(plan_lot.errors.messages[:etp_address_id]).to include(error_message) }
          end

          context 'other' do
            let!(:plan_lot) { build(:plan_lot, :zpp, :etp_b2b) }

            it { expect(plan_lot.errors.messages[:etp_address_id]).not_to include(error_message) }
          end
        end

        context 'etp_address is not_etp' do
          context 'when in list' do
            let!(:plan_lot) { build(:plan_lot, :non_etp, tender_type_id: Constants::TenderTypes::NON_ETP.sample) }

            it { expect(plan_lot.errors.messages[:etp_address_id]).not_to include(error_message) }
          end

          context 'other' do
            let!(:plan_lot) { build(:plan_lot, :zpp, :non_etp) }

            it { expect(plan_lot.errors.messages[:etp_address_id]).not_to include(error_message) }
          end
        end
      end

      describe 'must etp' do
        let(:error_message) { "должен быть ЭТП" }

        context 'when in list' do
          let!(:plan_lot) { build(:plan_lot, :non_etp, tender_type_id: Constants::TenderTypes::ETP.sample) }

          it { expect(plan_lot.errors.messages[:etp_address_id]).to include(error_message) }
        end
      end
    end

    describe '#valid_1kk' do
      let(:plan_spec) { build(:plan_specification) }
      let(:error_message) { "Можно выбрать комиссию только 1 уровня КК" }

      context 'organizer is not a customer or this is not rao' do
        it do
          expect(plan_lot.valid?).to eq(true)
          expect(plan_lot.errors.messages[:base]).to be_empty
        end
      end

      context 'tender is single_source or unregulated' do
        let!(:plan_lot) { build(:plan_lot, :own, :single_source, commission: nil, root_customer: plan_spec.customer, plan_specifications: [plan_spec]) }

        it 'single_source' do
          plan_lot.valid?
          expect(plan_lot.errors.messages[:commission_id]).not_to include(error_message)
        end

        it 'unregulated' do
          allow_any_instance_of(PlanLot).to receive(:unregulated?).and_return(true)
          plan_lot.valid?
          expect(plan_lot.errors.messages[:commission_id]).not_to include(error_message)
        end
      end

      context 'organizer is a customer' do
        context 'commission is 2 kk' do
          let!(:plan_lot) { build(:plan_lot, :own, commission: create(:commission, :level2_kk), root_customer: plan_spec.customer, plan_specifications: [plan_spec]) }

          it do
            plan_lot.valid?
            expect(plan_lot.errors.messages[:commission_id]).to include(error_message)
          end
        end

        context 'commission is 1 kk' do
          let!(:plan_lot) { build(:plan_lot, :own, commission: create(:commission, :level1_kk), root_customer: plan_spec.customer, plan_specifications: [plan_spec]) }

          it do
            plan_lot.valid?
            expect(plan_lot.errors.messages[:commission_id]).not_to include(error_message)
          end
        end

        context 'commission is szk' do
          let!(:plan_lot) { build(:plan_lot, :own, commission: create(:commission, :szk), root_customer: plan_spec.customer, plan_specifications: [plan_spec]) }

          it do
            plan_lot.valid?
            expect(plan_lot.errors.messages[:commission_id]).to include(error_message)
          end
        end

        context 'commission is czk' do
          let!(:plan_lot) { build(:plan_lot, :own, commission: create(:commission, :czk), root_customer: plan_spec.customer, plan_specifications: [plan_spec]) }

          it do
            plan_lot.valid?
            expect(plan_lot.errors.messages[:commission_id]).to include(error_message)
          end
        end

        context 'commission is sd' do
          let!(:plan_lot) { build(:plan_lot, :own, commission: create(:commission, :sd), root_customer: plan_spec.customer, plan_specifications: [plan_spec]) }

          it do
            plan_lot.valid?
            expect(plan_lot.errors.messages[:commission_id]).to include(error_message)
          end
        end
      end
    end

    it 'return true' do
      expect(plan_lot_with_contract.contract?).to be true
    end

    it 'return false' do
      expect(plan_lot.contract?).to be false
    end
  end

  describe "can_execute?" do
    subject { plan_lot.can_execute? }
    context 'lots exists' do
      let!(:lot) { create(:lot, :public) }
      let(:plan_lot) { lot.plan_lot }
      it { expect(subject).to eq false }
    end
    context 'lot has contract_termination' do
      let!(:plan_lot_confirm) { create(:plan_lot_with_specs, :confirm_sd) }
      let!(:plan_lot) { create(:plan_lot_with_specs, :version2, :agreement, guid: plan_lot_confirm.guid) }
      let!(:lot) { create(:lot_with_contract_termination, :contract, plan_lot: plan_lot_confirm) }
      it { expect(subject).to eq true }
    end
    context 'lot is not already published' do
      let(:plan_lot) { create(:plan_lot) }
      it { expect(subject).to eq true }
    end
    context 'lot is already published' do
      let!(:plan_lot_confirm) { create(:plan_lot, :confirm_sd) }
      let!(:plan_lot) { create(:plan_lot, :version2, :agreement, guid: plan_lot_confirm.guid) }
      let!(:lot) { create(:lot, :public, plan_lot: plan_lot_confirm) }
      it { expect(subject).to eq false }
    end
  end

  context "::additional_search" do
    let(:department) { create(:department) }

    it 'found' do
      plan_lot = create(:plan_lot, :agreement, num_tender: 123, root_customer_id: department.id)
      expect(PlanLot.additional_search('123', department.id).to_a).to eq([plan_lot])
    end
  end

  context "trigger #lot_before_create" do
    it "update prev version" do
      pl = create(:plan_lot)
      create(:plan_lot, guid: pl.guid)
      pl.reload
      expect(pl.version).to eq(1)
    end
  end

  it "for class method preselection_search" do
    dep = create(:department)
    pl1 = create(:plan_lot_with_specs,
                 :new, :ttype_po,
                 root_customer: dep,
                 num_tender: '123',
                 lot_name: 'Lorem ipsum dolor sit amet')
    pl2 = create(:plan_lot_with_specs,
                 :agreement,
                 root_customer: dep,
                 num_tender: '456',
                 lot_name: 'Lorem ipsum dolor sit amet')
    pl3 = create(:plan_lot_with_specs,
                 :import, :ttype_po,
                 root_customer: dep,
                 num_tender: '789',
                 lot_name: 'Lorem ipsum dolor sit amet')
    expect(PlanLot.preselection_search('dolor', dep.id)).to eq([pl1])
  end

  it "invalid announce date for from-preselection tender" do
    preselection = create(:plan_lot, :ttype_po, announce_date: "2015-09-01")
    lot = build(:plan_lot, announce_date: "2015-09-01", preselection_guid: preselection.guid)
    lot.valid?
    expect(lot.errors[:announce_date].join).to include("через 25 дней")
  end

  context 'orders validations' do
    let(:plan_lot) { build(:plan_lot) }
    let(:plan_lot_with_order) { build(:plan_lot_with_order) }
    let(:plan_with_org_eq_cust) { build(:plan_lot, :organizer_eq_customer) }
    let(:order_approved) { create(:order, :approved) }
    let(:plan_lot_with_approved_order) do
      pl = create(:plan_lot_with_order)
      pl.orders << order_approved
      pl
    end
    let(:lot_with_order) { create(:lot_with_order) }

    describe '#customer_is_organizer?' do
      it 'return true if organizer equal customer' do
        expect(plan_with_org_eq_cust.customer_is_organizer?).to eq(true)
      end

      it 'return false if organizer not equal customer' do
        expect(plan_lot.customer_is_organizer?).to eq(false)
      end
    end

    describe '#all_orders' do
      it 'return array of all orders of all plan lot versions' do
        expect(plan_lot_with_approved_order.all_orders).to eq(plan_lot_with_approved_order.orders)
      end
    end

    describe '#last_valid_order' do
      it 'return valid last approved order' do
        expect(plan_lot_with_approved_order.last_valid_order).to eq(order_approved)
      end
    end

    describe '#confirmed_order?' do
      it 'return true if plan lot has approved order' do
        expect(plan_lot_with_approved_order.confirmed_order?).to eq(true)
      end

      it 'return false if plan lot has not approved order' do
        expect(plan_lot_with_order.confirmed_order?).to eq(false)
      end

      it 'return false if there is no any order' do
        expect(plan_lot.confirmed_order?).to eq(false)
      end
    end

    describe '#order_not_published?' do
      it 'return true if last order is not published' do
        expect(plan_lot_with_approved_order.order_not_published?).to eq(true)
      end

      it 'return false if last order is published' do
        expect(lot_with_order.plan_lot.order_not_published?).to eq(false)
      end

      it 'return false if there is no any order' do
        expect(plan_lot.order_not_published?).to eq(false)
      end
    end
  end

  describe "checking lot type" do
    let(:single_source) { build(:plan_lot, :single_source) }
    let(:unregulated) { build(:plan_lot, :unregulated) }
    let(:zpp) { build(:plan_lot, :zpp) }
    let(:preselection) { build(:plan_lot, :ttype_po) }


    context '#only_source?' do
      it "true" do
        expect(single_source.only_source?).to be_truthy
      end
      it "false" do
        expect(unregulated.only_source?).to be_falsey
      end
    end

    context '#regulated?' do
      it "true" do
        expect(single_source.regulated?).to be_truthy
      end
      it "false" do
        expect(unregulated.regulated?).to be_falsey
      end
    end

    context '#unregulated?' do
      it "true" do
       expect(unregulated.unregulated?).to be_truthy
      end
      it "false" do
        expect(single_source.unregulated?).to be_falsey
      end
    end

    context '#zpp?' do
      it "true" do
       expect(zpp.zpp?).to be_truthy
      end
      it "false" do
        expect(single_source.zpp?).to be_falsey
      end
    end

    context '#preselection?' do
      it "true" do
       expect(preselection.preselection?).to be_truthy
      end
      it "false" do
        expect(single_source.preselection?).to be_falsey
      end
    end
  end

  describe '#cost' do
    it 'is sum all total_costs from plan_specifications' do
      lot = build(:plan_lot,
        plan_specifications: [build(:plan_specification), build(:plan_specification)]
      )
      allow_any_instance_of(PlanSpecification).to receive(:total_cost).and_return 4_000
      expect(lot.cost).to eq(8_000)
    end
  end

  describe '#cost_nds' do
    it 'is sum all total_costs from plan_specifications' do
      lot = build(:plan_lot,
        plan_specifications: [build(:plan_specification), build(:plan_specification)]
      )
      allow_any_instance_of(PlanSpecification).to receive(:total_cost_nds).and_return 4_000
      expect(lot.cost_nds).to eq(8_000)
    end
  end

  describe '#okdp_in_sme?' do
    let(:pl) { create(:plan_lot_with_specs) }
    it 'return true if okdp in sme list' do
      allow(OkdpSmeEtp).to receive(:exists?).and_return true
      expect(pl.send(:okdp_in_sme?)).to be_truthy
    end
    it 'return false if okdp not in sme list' do
      allow(OkdpSmeEtp).to receive(:exists?).and_return false
      expect(pl.send(:okdp_in_sme?)).to be_falsey
    end
  end

  describe '#cost_nds_greater_then_eis223_limit?' do
    let(:pl) { build(:plan_lot_with_specs) }
    let(:root_customer_eis223_limit) { Faker::Number.number(5).to_i }
    before(:example) { allow(pl).to receive(:root_customer_eis223_limit).and_return(root_customer_eis223_limit) }
    it 'return true if root_customer_eis223_limit > cost_nds' do
      allow(pl).to receive(:cost_nds).and_return(root_customer_eis223_limit + 1)
      expect(pl.send(:cost_nds_greater_then_eis223_limit?)).to eq(true)
    end

    it 'return false if root_customer_eis223_limit <= cost_nds' do
      allow(pl).to receive(:cost_nds).and_return(root_customer_eis223_limit - 1)
      expect(pl.send(:cost_nds_greater_then_eis223_limit?)).to eq(false)
    end
  end

  describe 'public_eis?' do
    context "should not be public" do
      it "unregulated tenders" do
        lot = build(:plan_lot, :unregulated)
        expect(lot.public_eis?).to be_falsey
      end
    end

    context "should be public" do
      it "raoesv and regulated tenders" do
        lot = build(:plan_lot, :single_source)
        expect(lot.public_eis?).to be_truthy
      end
    end
  end

  shared_examples 'fill sme_type depending on okdp code' do
    context 'and okdp code in sme list' do
      before(:example) { allow(pl).to receive(:okdp_in_sme?).and_return(true) }

      context 'and sme_type is not filled' do
        before(:example) { allow(pl).to receive(:sme_type_id).and_return(nil) }
        it 'fail validation' do
          pl.valid?
          expect(pl.errors.messages[:sme_type_id]).to include(error_messag_msp)
        end
      end
      context 'and sme_type is filled' do
        before(:example) { allow(pl).to receive(:sme_type_id).and_return(SmeTypes::SME) }
        it 'pass validation' do
          pl.valid?
          expect(pl.errors.messages[:sme_type_id]).to_not include(error_messag_msp)
        end
      end
    end
    context 'and okdp code not in sme list' do
      before(:example) { allow(pl).to receive(:okdp_in_sme?).and_return(false) }

      context 'and sme_type is filled' do
        before(:example) { allow(pl).to receive(:sme_type_id).and_return(SmeTypes::SME) }
        it 'fail validation' do
          pl.valid?
          expect(pl.errors.messages[:sme_type_id]).to include(error_message_non_msp)
        end
      end
      context 'and sme_type is not filled' do
        before(:example) { allow(pl).to receive(:sme_type_id).and_return(nil) }
        it 'pass validation' do
          pl.valid?
          expect(pl.errors.messages[:sme_type_id]).to_not include(error_message_non_msp)
        end
      end
    end
  end

  shared_examples 'set sme_type always empty' do
    context 'and sme_type is filled' do
      before(:example) { allow(pl).to receive(:sme_type_id).and_return(SmeTypes::SME) }
      it 'fail validation' do
        pl.valid?
        expect(pl.errors.messages[:sme_type_id]).to include(error_message)
      end
    end
    context 'and sme_type is not filled' do
      before(:example) { allow(pl).to receive(:sme_type_id).and_return(nil) }
      it 'pass validation' do
        pl.valid?
        expect(pl.errors.messages[:sme_type_id]).to_not include(error_message)
      end
    end
  end
end

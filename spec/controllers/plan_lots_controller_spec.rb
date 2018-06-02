# frozen_string_literal: true

require 'spec_helper'
include Constants

RSpec.describe PlanLotsController, type: :controller do
  let(:user) { create(:user_user) }
  let(:moderator) { create(:user_moderator) }
  let(:boss) { create(:user_boss) }
  let(:department) { create(:department) }
  let(:consumer) { create(:department, :consumer, :child) }
  let(:production_unit) { create(:department, :child) }
  let(:commission) { create(:commission, :level1_kk) }
  let(:contractor1) { create(:contractor) }
  let(:contractor2) { create(:contractor) }
  let(:contractor3) { create(:contractor) }
  let!(:unit) { create(:unit, :default_unit) }
  let(:pl) { create(:plan_lot_with_specs, :own) }
  let(:regulation_item) { create(:regulation_item) }
  let(:direction) { create(:direction) }
  let(:fias) { create(:fias) }

  let(:filter) do
    {
      years: ["2016"],
      state: "",
      gkpz_state: "current",
      gkpz_on_date_begin: "",
      gkpz_on_date_end: "",
      declared: "",
      date_begin: "",
      date_end: "",
      name: "",
      num: "",
      control_lots: "0"
    }
  end

  let(:valid_params_without_spec) do
    {
      is_additional: "0",
      additional_to_hex: "",
      additional_num: "",
      gkpz_year: "2016",
      num_tender: "32",
      num_lot: "1",
      announce_date: "15.09.2016",
      subject_type_id: SubjectType::MATERIALS,
      tender_type_id: TenderTypes::OOK,
      etp_address_id: EtpAddress::NOT_ETP,
      point_clause: "",
      regulation_item_id: regulation_item.id,
      preselection_guid_hex: "",
      tender_type_explanations: "",
      lot_name: "aaa",
      #department_id: department.id,
      commission_id: commission.id,
      sme_type_id: "",
      order1352_id: Order1352::EXCLUSIONS.first,
      plan_lot_contractors_attributes: {
        "0" => { contractor_id: contractor1.id },
        "1" => { contractor_id: contractor2.id },
        "2" => { contractor_id: contractor3.id }
       }
    }
  end
  let(:invalid_params_without_spec ) { valid_params_without_spec.merge(num_tender: "") }

  let(:valid_params) do
    {
      is_additional: "0",
      additional_to_hex: "",
      additional_num: "",
      gkpz_year: "2016",
      num_tender: "32",
      num_lot: "1",
      announce_date: "15.09.2016",
      subject_type_id: SubjectType::MATERIALS,
      tender_type_id: TenderTypes::OOK,
      etp_address_id: EtpAddress::NOT_ETP,
      point_clause: "",
      regulation_item_id: regulation_item.id,
      preselection_guid_hex: "",
      tender_type_explanations: "",
      lot_name: "aaa",
      department_id: department.id,
      commission_id: commission.id,
      sme_type_id: "",
      order1352_id: Order1352::EXCLUSIONS.first,
      plan_lot_contractors_attributes: {
        "0" => { contractor_id: contractor1.id },
        "1" => { contractor_id: contractor2.id },
        "2" => { contractor_id: contractor3.id }
      },
      plan_specifications_attributes: {
        "0" => {
          gkpz_year: "2016",
          guid_hex: "",
          num_spec: "1",
          qty: "1",
          cost_money: "100.00",
          nds: "18",
          cost_nds_money: "118.00",
          unit_name: "усл. ед",
          product_type_id: ProductTypes::PIR,
          cost_doc: "",
          direction_id: direction.id,
          financing_id: Financing::COST_PRICE,
          bp_state_id: 1,
          name: "aaa",
          requirements: "bbb",
          bp_item: "ccc",
          customer_id: department.id,
          consumer_id: consumer.id,
          delivery_date_begin: "17.09.2016",
          delivery_date_end: "23.09.2016",
          monitor_service_id: department.id,
          curator: "Иван",
          tech_curator: "Петр",
          note: "",
          production_unit_ids: [production_unit.id],
          fias_plan_specifications_attributes: {
            "0" => { addr_aoid_hex: fias.aoid_hex, fias_id: fias.id },
          },
          invest_project_id: "",
          invest_name: "",
          okdp_id: create(:okdp_type_new).id,
          okved_id: create(:okved_new).id,
          plan_spec_amounts_attributes: {
            "0" => {
              year: "2016",
              amount_mastery_money: "100.00",
              amount_mastery_nds_money: "118.00",
              amount_finance_money: "100.00",
              amount_finance_nds_money: "118.00",
            },
          },
        },
      },
    }
  end
  let(:invalid_params) { valid_params.merge(num_tender: "") }

  before(:each) { sign_in(user) }

  describe "GET index" do
    it "select index template for rendering" do
      allow(PlanFilter).to receive(:new)
      get :index
      expect(response).to render_template(:index)
    end

    it "make plan_filter avail able for template" do
      fake_result = double(PlanFilter)
      allow(PlanFilter).to receive(:new).and_return(fake_result)
      get :index
      expect(assigns(:plan_filter)).to eq(fake_result)
    end

    context "without plan_filter params" do
      it "call method new without empty params" do
        expect(PlanFilter).to receive(:new).with(nil)
        get :index
      end
    end

    context "with plan_filter params" do
      let(:fake_results) { double(ActiveRecord::Relation) }
      let(:plan_filter) { instance_double(PlanFilter, valid?: true, search: fake_results) }

      before(:each) do
        allow(PlanFilter).to receive(:new).and_return plan_filter
        allow_any_instance_of(PlanFilter).to receive(:valid?).and_return(true)
      end

      it "make plan_lots available for template" do
        allow_any_instance_of(PlanFilter).to receive(:search)
        allow(fake_results).to receive(:page).and_return(fake_results)
        allow_any_instance_of(User).to receive_message_chain(:plan_lots, :page)

        get :index, params: { plan_filter: filter }

        expect(assigns(:plan_lots)).to eq(fake_results)
      end

      it "make plan_lots available for template" do
        allow_any_instance_of(PlanFilter).to receive(:search)
        allow(fake_results).to receive(:page)
        allow_any_instance_of(User).to receive_message_chain(:plan_lots, :page).and_return(fake_results)

        get :index, params: { plan_filter: filter }

        expect(assigns(:plan_selected_lots)).to eq(fake_results)
      end

      it "call instance method search" do
        expect(plan_filter).to receive(:search)

        allow(fake_results).to receive(:page)
        allow_any_instance_of(User).to receive_message_chain(:plan_lots, :page)

        get :index, params: { plan_filter: filter }
      end
    end
  end

  describe "GET show" do
    it "success" do
      get :show, params: { id: pl.id }
      assert_response :success
    end
  end

  describe "GET new" do
    it "success" do
      get :new
      assert_response :success
    end
  end

  describe "POST create" do
    it "success" do
      assert_difference 'PlanLot.count' do
        post :create, params: { plan_lot: valid_params }
      end

      assert_redirected_to plan_lot_url(PlanLot.last)
    end

    it "non valid" do
      assert_no_difference 'PlanLot.count' do
        post :create, params: { plan_lot: invalid_params }
      end

      assert_template :new
    end
  end

  describe "GET edit" do
    it "success" do
      get :edit, params: { id: pl.id }
      assert_response :success
    end
  end

  describe "PATCH update" do
    it "success" do
      plan_lot = pl
      assert_difference 'PlanLot.count' do
        patch :update, params: { id: plan_lot.id, plan_lot: valid_params }
      end
      assert_redirected_to plan_lot_url(PlanLot.last)
    end

    it "non valid" do
      plan_lot = pl
      assert_no_difference 'PlanLot.count' do
        patch :update, params: { id: plan_lot.id, plan_lot: invalid_params }
      end
      assert_template :edit
    end
  end

  describe "DELETE destroy" do
    it "success" do
      plan_lot = pl
      assert_difference('PlanLot.count', -1) do
        delete :destroy, params: { id: plan_lot.id }
      end

      assert_redirected_to plan_lots_url
    end

    it "not success" do
      plan_lot = create(:plan_lot_with_specs, :agreement)
      assert_no_difference('PlanLot.count') do
        delete :destroy, params: { id: plan_lot.id }
      end

      assert_redirected_to root_url
    end
  end

  describe "GET history_lot" do
    it "success" do
      get :history_lot, params: { guid: pl.guid_hex }
      assert_response :success
    end
  end

  describe "GET history_lot_full" do
    it "success" do
      get :history_lot_full, params: { guid: pl.guid_hex }
      assert_response :success
    end
  end

  describe "GET history_spec" do
    it "success" do
      get :history_spec, params: { guid: pl.plan_specifications[0].guid_hex }
      assert_response :success
    end
  end

  describe "GET edit_without_history" do
    it "success" do
      sign_in(moderator)
      get :edit_without_history, params: { id: pl.id }
      assert_response :success
    end
  end

  describe "PATCH update_without_history" do
    it "success" do
      sign_in(moderator)
      plan_lot = pl
      assert_no_difference 'PlanLot.count' do
        patch :update_without_history, params: { id: plan_lot.id, plan_lot: valid_params_without_spec }
      end
      assert_redirected_to history_plan_lot_url(plan_lot.guid_hex)
    end

    it "non valid" do
      sign_in(moderator)
      plan_lot = pl
      assert_no_difference 'PlanLot.count' do
        patch :update_without_history, params: { id: plan_lot.id, plan_lot: invalid_params_without_spec }
      end
      assert_template :edit_without_history
    end
  end

  describe "DELETE destroy_current_version_user" do
    it "success" do
      plan_lot = create(:plan_lot_with_specs, :new, user: user)
      assert_difference('PlanLot.count', -1) do
        delete :destroy_current_version_user, params: { guid: plan_lot.guid_hex }
      end

      assert_redirected_to history_plan_lot_url(plan_lot.guid_hex)
    end

    it "not success" do
      plan_lot = create(:plan_lot_with_specs, :agreement, user: user)
      assert_no_difference('PlanLot.count') do
        delete :destroy_current_version_user, params: { guid: plan_lot.guid_hex }
      end

      assert_redirected_to history_plan_lot_url(plan_lot.guid_hex)
    end

    it "not success" do
      plan_lot = create(:plan_lot_with_specs, :new)
      assert_no_difference('PlanLot.count') do
        delete :destroy_current_version_user, params: { guid: plan_lot.guid_hex }
      end

      assert_redirected_to history_plan_lot_url(plan_lot.guid_hex)
    end
  end

  describe "DELETE destroy_version" do
    it "success" do
      sign_in(moderator)
      plan_lot = pl
      assert_difference('PlanLot.count', -1) do
        delete :destroy_version, params: { id: plan_lot.id }
      end

      assert_redirected_to history_plan_lot_url(plan_lot.guid_hex)
    end

    it "not success" do
      sign_in(moderator)
      tender = create(:tender_with_new_lot)
      plan_lot = tender.lots[0].plan_lot
      assert_no_difference('PlanLot.count') do
        delete :destroy_version, params: { id: plan_lot.id }
      end

      assert_redirected_to history_plan_lot_url(plan_lot.guid_hex)
    end
  end

  describe "DELETE destroy_all" do
    it "success" do
      user.plan_lots = [pl, create(:plan_lot_with_specs)]
      assert_difference('PlanLot.count', -2) do
        delete :destroy_all
      end
      assert_redirected_to plan_lots_path
    end
    it "not success" do
      user.plan_lots = [pl, create(:plan_lot_with_specs, :agreement)]
      assert_no_difference('PlanLot.count') do
        delete :destroy_all
      end
      assert_redirected_to root_url
    end
  end

  describe "GET export_excel" do
    it "success" do
      get :export_excel, params: { format: :xlsx }
      assert_response :success
    end
  end

  describe "GET export_excel_lot" do
    it "calls search_excel_lot" do
      expect_any_instance_of(PlanFilter).to receive(:search_excel_lot)
      get :export_excel_lot, params: { format: :xlsx }
    end
    it "selects the 'plan_lots' template for rendering" do
      allow_any_instance_of(PlanFilter).to receive(:search_excel_lot)
      get :export_excel_lot, params: { format: :xlsx }
      expect(response).to render_template(:plan_lots)
    end
    it "make search results available for template" do
      fake_results = [double(PlanLot), double(PlanLot)]
      allow_any_instance_of(PlanFilter).to receive(:search_excel_lot).and_return(fake_results)
      get :export_excel_lot, params: { format: :xlsx }
      expect(assigns(:plan_lots)).to eq(fake_results)
    end
  end

  describe "GET reset" do
    it "success" do
      get :reset
      assert_redirected_to new_plan_lot_url
    end
  end

  describe "GET import_excel" do
    it "success" do
      get :import_excel
      assert_response :success
    end
  end

  describe "GET import_lots" do
    it "success" do
      get :import_lots
      assert_response :success
    end
  end

  describe "POST import" do
    it "success" do
      post :import
      assert_redirected_to plan_lots_url
    end
  end

  describe "POST upload_excel" do
    it "not success" do
      post :upload_excel
      assert_redirected_to import_excel_plan_lots_url
    end
  end

  describe "POST next_free_number" do
    it "success" do
      create(:plan_lot_with_specs, :new, root_customer: department, gkpz_year: 2016)
      post :next_free_number, params: { department_id: department.id, gkpz_year: 2016 }
      assert_response :success
    end
  end

  describe "PATCH submit_approval" do
    it "non success" do
      assert_no_difference 'PlanLot.count' do
        patch :submit_approval
      end
      assert_redirected_to plan_lots_url
    end
  end

  describe "PATCH return_for_revision" do
    it "non success" do
      assert_no_difference 'PlanLot.count' do
        patch :return_for_revision
      end
      assert_redirected_to plan_lots_url
    end
  end

  describe "PATCH agree" do
    it "non success" do
      sign_in(boss)
      assert_no_difference 'PlanLot.count' do
        patch :agree
      end
      assert_redirected_to plan_lots_url
    end
  end

  describe "PATCH pre_confirm_sd" do
    it "non success" do
      assert_no_difference 'PlanLot.count' do
        patch :pre_confirm_sd
      end
      assert_redirected_to plan_lots_url
    end
  end

  describe "PATCH cancel_pre_confirm_sd" do
    it "non success" do
      sign_in(boss)
      assert_no_difference 'PlanLot.count' do
        patch :cancel_pre_confirm_sd
      end
      assert_redirected_to plan_lots_url
    end
  end

  describe "GET preselection_search" do
    it "success" do
      create(:plan_lot_with_specs, :new, :ttype_po, root_customer: department, num_tender: '123')
      get :preselection_search, params: { q: '123', cust_id: department.id }, xhr: true
      assert_response :success
    end
  end

  describe "GET additional_search" do
    it "success" do
      create(:plan_lot_with_specs, :new, root_customer: department, num_tender: '123')
      get :additional_search, params: { q: '123', cust_id: department.id }, xhr: true
      assert_response :success
    end
  end

  describe "GET additional_info" do
    it "success" do
      pl = create(:plan_lot_with_specs, :new, root_customer: department, num_tender: '123')
      get :additional_info, params: { guid: pl.guid_hex }, xhr: true
      assert_response :success
    end
  end

  describe "GET reform_okveds" do
    it "success" do
      get :reform_okveds, params: {
        okdp: pl.plan_specifications[0].okdp_id, okved: pl.plan_specifications[0].okved_id
      }, xhr: true
      assert_response :success
    end
  end

  describe "GET preselection_info" do
    it "success" do
      po = create(:plan_lot_with_specs, :confirm_sd, :ttype_po)
      zzc = create(:plan_lot_with_specs, :agreement,
                                         tender_type_id: Constants::TenderTypes::ZZC,
                                         preselection_guid_hex: po.guid_hex,
                                         announce_date: po.announce_date + 30.days)
      get :preselection_info, params: { id: po.id }
      assert_response :success
    end
  end

  describe "GET search_edit_list" do
    it "success" do
      pl = create(:plan_lot_with_specs, :new, root_customer: department, num_tender: '123')
      user.plan_lots << pl
      get :search_edit_list, params: { q: pl.lot_name }, xhr: true
      assert_response :success
    end
  end

  describe "GET search_all" do
    it "success" do
      pl = create(:plan_lot_with_specs, :new, root_customer: department, num_tender: '123')
      get :search_all, params: { q: pl.lot_name, all: true }, xhr: true
      assert_response :success
    end
  end

  describe 'GET copy_plan_specifications' do
    before(:example) do
      pl = create(:plan_lot_with_specs, :new, root_customer: department)
      user.plan_lots << pl
    end
    context 'when all lots has one root customer' do
      it 'success' do
        pl = create(:plan_lot_with_specs, :new, root_customer: department)
        user.plan_lots << pl
        get :copy_plan_specifications
        assert_template :copy_plan_specifications
      end
    end
    context 'when lots has different root customers' do
      it 'fail' do
        another_department = create(:department)
        pl = create(:plan_lot_with_specs, :new, root_customer: another_department)
        user.plan_lots << pl
        get :copy_plan_specifications
        expect(flash[:alert]).to eq(I18n.t('plan_lots.copy_plan_specifications.diff_root_customers'))
      end
    end
  end
end

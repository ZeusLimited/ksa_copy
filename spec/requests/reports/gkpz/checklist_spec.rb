# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "Reports::Gkpz::Checklist", type: :request do
  describe "GET /reports/gkpz/checklist/options" do
    before { get reports_gkpz_checklist_options_url, headers: auth_headers }
    it { expect(response).to have_http_status(200) }
    it { expect(response).to render_template(:options) }
  end

  describe "GET /reports/gkpz/checklist/show" do
    before { get reports_gkpz_checklist_show_url, params: params, headers: auth_headers }

    let(:params) { { reports_gkpz_checklist: reports_params } }

    let(:reports_params) do
      {
        date_begin: plan_lot.announce_date - 1.day,
        date_end: plan_lot.announce_date + 10.days,
        date_gkpz_on_state: plan_lot.protocol.date_confirm,
        gkpz_year: plan_lot.gkpz_year,
        gkpz_type: 'all_gkpz_unplanned',
        gkpz_state: plan_lot.state,
        customer: plan_lot.root_customer_id,
        organizers: [plan_lot.department_id],
        etp_addresses: [plan_lot.etp_address_id],
        tender_types: [plan_lot.tender_type_id],
        directions: [plan_lot.plan_specifications[0].direction_id],
        subject_type: plan_lot.subject_type_id,
        statuses: [plan_lot.status_id],
      }
    end

    let(:plan_lot) { create(:plan_lot_with_specs, :own, :agreement) }

    it { expect(response).to have_http_status(200) }
  end
end

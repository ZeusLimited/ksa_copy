# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "Reports::Gkpz::Gkpz", type: :request do
  describe "GET /reports/gkpz/gkpz/options" do
    before { get reports_gkpz_gkpz_options_url, headers: auth_headers }

    it { expect(response).to have_http_status(200) }
    it { expect(response).to render_template(:options) }
  end

  describe "GET /reports/gkpz/gkpz/show" do
    before { get reports_gkpz_gkpz_show_url, params: params, headers: auth_headers }

    let(:params) { { reports_gkpz_gkpz: reports_params } }

    let(:plan_lot) { create(:plan_lot_with_specs, :own, :agreement) }

    let(:reports_params) do
      {
        date_begin: plan_lot.announce_date - 1.day,
        date_end: plan_lot.announce_date + 10.days,
        date_gkpz_on_state: plan_lot.protocol.date_confirm,
        gkpz_years: [plan_lot.gkpz_year],
        gkpz_type: 'all_gkpz_unplanned',
        gkpz_state: plan_lot.state,
        customers: [plan_lot.root_customer_id],
        organizers: [plan_lot.department_id],
        etp_addresses: [plan_lot.etp_address_id],
        tender_types: [plan_lot.tender_type_id],
        directions: [plan_lot.plan_specifications[0].direction_id],
        subject_types: [plan_lot.subject_type_id],
        statuses: [plan_lot.status_id],
        show_status: 1,
        show_root: 1,
        show_cust: 1,
        status_tender: 1,
        show_color: 1,
        divide_by_customers: 1,
      }
    end

    it { expect(response).to have_http_status(200) }
  end
end

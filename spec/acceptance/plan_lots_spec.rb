require 'acceptance_helper'

resource 'Планирование', acceptance: true do
  header 'Authorization', :auth_header
  let(:auth_header) { ActionController::HttpAuthentication::Basic.encode_credentials(user.login, password) }

  let(:user) { create(:user_user, password: password) }
  let(:password) { Faker::Internet.password(8, 12) }

  get '/plan_lots' do
    parameter :years, I18n.t('docs.filters.years'), scope: :plan_filter
    parameter :state, I18n.t('docs.filters.state'), scope: :plan_filter
    parameter :gkpz_state, I18n.t('docs.filters.gkpz_state'), scope: :plan_filter
    parameter :gkpz_on_date_begin, I18n.t('docs.filters.gkpz_on_date_begin'), scope: :plan_filter
    parameter :gkpz_on_date_end, I18n.t('docs.filters.gkpz_on_date_end'), scope: :plan_filter
    parameter :customers, I18n.t('docs.filters.customers'), scope: :plan_filter
    parameter :organizers, I18n.t('docs.filters.organizers'), scope: :plan_filter
    parameter :monitor_services, I18n.t('docs.filters.monitor_services'), scope: :plan_filter
    parameter :date_begin, I18n.t('docs.filters.announce_date_begin'), scope: :plan_filter
    parameter :date_end, I18n.t('docs.filters.announce_date_end'), scope: :plan_filter
    parameter :directions, I18n.t('docs.filters.directions'), scope: :plan_filter
    parameter :subject_types, I18n.t('docs.filters.subject_types'), scope: :plan_filter
    parameter :tender_types, I18n.t('docs.filters.tender_types'), scope: :plan_filter
    parameter :statuses, I18n.t('docs.filters.statuses'), scope: :plan_filter
    parameter :etp_addresses, I18n.t('docs.filters.etp_addresses'), scope: :plan_filter
    parameter :declared, I18n.t('docs.filters.declared'), scope: :plan_filter
    parameter :name, I18n.t('docs.filters.name'), scope: :plan_filter
    parameter :num, I18n.t('docs.filters.num'), scope: :plan_filter
    parameter :control_lots, I18n.t('docs.filters.control_lots'), scope: :plan_filter
    parameter :start_cost, I18n.t('docs.filters.start_cost'), scope: :plan_filter
    parameter :end_cost, I18n.t('docs.filters.end_cost'), scope: :plan_filter
    parameter :consumers, I18n.t('docs.filters.consumers'), scope: :plan_filter
    parameter :sme_types, I18n.t('docs.filters.sme_types'), scope: :plan_filter
    parameter :order1352, I18n.t('docs.filters.order1352'), scope: :plan_filter
    parameter :okdp, I18n.t('docs.filters.okdp'), scope: :plan_filter
    parameter :okved, I18n.t('docs.filters.okved'), scope: :plan_filter
    parameter :bp_states, I18n.t('docs.filters.bp_states'), scope: :plan_filter
    parameter :bidders, I18n.t('docs.filters.potential_bidders'), scope: :plan_filter
    parameter :regulation_items, I18n.t('docs.filters.regulation_items'), scope: :plan_filter

    let(:plan_lot) { create(:plan_lot_with_specs) }

    let(:years) { [plan_lot.gkpz_year] }
    let(:num) { plan_lot.full_num }

    example 'Поиск лотов' do
      do_request
      expect(status).to eq(200)
    end
  end

  get '/plan_lots/:id' do
    let(:id) { create(:plan_lot_with_specs).id }

    parameter :id, required: true

    example 'Просмотр лота' do
      do_request
      expect(status).to eq(200)
    end
  end
end

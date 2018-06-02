require 'acceptance_helper'

resource 'Исполнение', acceptance: true do
  header 'Authorization', :auth_header
  let(:auth_header) { ActionController::HttpAuthentication::Basic.encode_credentials(user.login, password) }

  let(:user) { create(:user_user, password: password) }
  let(:password) { Faker::Internet.password(8, 12) }

  get '/tenders' do
    parameter :years, I18n.t('docs.filters.years'), scope: :tender_filter
    parameter :customers, I18n.t('docs.filters.customers'), scope: :tender_filter
    parameter :organizers, I18n.t('docs.filters.organizers'), scope: :tender_filter
    parameter :monitor_services, I18n.t('docs.filters.monitor_services'), scope: :tender_filter
    parameter :announce_date_begin, I18n.t('docs.filters.announce_date_begin'), scope: :tender_filter
    parameter :announce_date_end, I18n.t('docs.filters.announce_date_end'), scope: :tender_filter
    parameter :directions, I18n.t('docs.filters.directions'), scope: :tender_filter
    parameter :subject_types, I18n.t('docs.filters.subject_types'), scope: :tender_filter
    parameter :statuses, I18n.t('docs.filters.statuses'), scope: :tender_filter
    parameter :tender_types, I18n.t('docs.filters.tender_types'), scope: :tender_filter
    parameter :etp_addresses, I18n.t('docs.filters.etp_addresses'), scope: :tender_filter
    parameter :search_by_name, I18n.t('docs.filters.search_by_name'), scope: :tender_filter
    parameter :search_by_num, I18n.t('docs.filters.search_by_num'), scope: :tender_filter
    parameter :search_by_gkpz_num, I18n.t('docs.filters.search_by_gkpz_num'), scope: :tender_filter
    parameter :by_winner, I18n.t('docs.filters.by_winner'), scope: :tender_filter
    parameter :control_lots, I18n.t('docs.filters.control_lots'), scope: :tender_filter
    parameter :search_by_contract_nums, I18n.t('docs.filters.search_by_contract_nums'), scope: :tender_filter
    parameter :wp_solutions, I18n.t('docs.filters.wp_solutions'), scope: :tender_filter
    parameter :consumers, I18n.t('docs.filters.consumers'), scope: :tender_filter
    parameter :etp_num, I18n.t('docs.filters.etp_num'), scope: :tender_filter
    parameter :wp_date_begin, I18n.t('docs.filters.wp_date_begin'), scope: :tender_filter
    parameter :wp_date_end, I18n.t('docs.filters.wp_date_end'), scope: :tender_filter
    parameter :contract_date_begin, I18n.t('docs.filters.contract_date_begin'), scope: :tender_filter
    parameter :contract_date_end, I18n.t('docs.filters.contract_date_end'), scope: :tender_filter
    parameter :bidders, I18n.t('docs.filters.bidders'), scope: :tender_filter
    parameter :start_cost, I18n.t('docs.filters.start_cost'), scope: :tender_filter
    parameter :end_cost, I18n.t('docs.filters.end_cost'), scope: :tender_filter
    parameter :start_tender_cost, I18n.t('docs.filters.start_tender_cost'), scope: :tender_filter
    parameter :end_tender_cost, I18n.t('docs.filters.end_tender_cost'), scope: :tender_filter
    parameter :sme_types, I18n.t('docs.filters.sme_types'), scope: :tender_filter
    parameter :regulation_items, I18n.t('docs.filters.regulation_items'), scope: :tender_filter
    parameter :order1352, I18n.t('docs.filters.order1352'), scope: :tender_filter
    parameter :bp_states, I18n.t('docs.filters.bp_states'), scope: :tender_filter
    parameter :plan_lot_guids, I18n.t('docs.filters.plan_lot_guids'), scope: :tender_filter
    parameter :okdp, I18n.t('docs.filters.okdp'), scope: :tender_filter
    parameter :okved, I18n.t('docs.filters.okved'), scope: :tender_filter
    parameter :users, I18n.t('docs.filters.users'), scope: :tender_filter

    let!(:tender) { create(:tender_with_lots) }

    let(:years) { tender.plan_lots.map(&:gkpz_year).uniq }
    let(:search_by_num) { tender.num }

    example 'Поиск закупочных процедур' do
      do_request
      expect(status).to eq(200)
    end
  end

  get '/tenders/:id' do
    let(:id) { create(:tender_with_lots).id }

    parameter :id, required: true

    example 'Просмотр закупочной процедуры' do
      do_request
      expect(status).to eq(200)
    end
  end

  get 'tenders/search_b2b_classifiers', document: false do
    let(:q) { create(:b2b_classifier).name }
    parameter :q, required: true

    example 'Get b2b classifiers by name' do
      do_request
      expect(status).to eq(200)
    end
  end

  get 'tenders/get_b2b_classifier', document: false do
    let(:classifier_id) { create(:b2b_classifier).classifier_id }
    parameter :classifier_id, required: true

    example 'Get b2b classifiers by ids' do
      do_request
      expect(status).to eq(200)
    end
  end
end

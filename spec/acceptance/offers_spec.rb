require 'acceptance_helper'

resource 'Исполнение: Оферты', acceptance: true do
  header 'Authorization', :auth_header
  let(:auth_header) { ActionController::HttpAuthentication::Basic.encode_credentials(user.login, password) }

  let(:user) { create(:user_user, password: password) }
  let(:password) { Faker::Internet.password(8, 12) }

  let(:tender) { create(:tender_with_public_lot) }
  let(:tender_id) { tender.id }
  let(:bidder_id) { create(:bidder, tender_id: tender_id).id }

  get '/tenders/:tender_id/bidders/:bidder_id/offers' do

    parameter :tender_id, I18n.t('docs.offers.tender_id'), required: true
    parameter :bidder_id, I18n.t('docs.offers.bidder_id'), required: true

    example 'Список' do
      do_request
      expect(status).to eq(200)
    end
  end

  post '/tenders/:tender_id/bidders/:bidder_id/offers' do
    parameter :tender_id, I18n.t('docs.offers.tender_id'), required: true
    parameter :bidder_id, I18n.t('docs.offers.bidder_id'), required: true

    parameter :lot_id, I18n.t('docs.offers.lot_id'), scope: :offer, required: true
    parameter :num, I18n.t('docs.offers.num'), scope: :offer, required: true
    parameter :status_id, I18n.t('docs.offers.status_id'), scope: :offer, required: true
    parameter :rebidded, I18n.t('docs.offers.rebidded'), scope: :offer
    parameter :maker, I18n.t('docs.offers.maker'), scope: :offer
    parameter :absent_auction, I18n.t('docs.offers.absent_auction'), scope: :offer
    parameter :conditions, I18n.t('docs.offers.conditions'), scope: :offer
    parameter :final_conditions, I18n.t('docs.offers.final_conditions'), scope: :offer
    parameter :change_descriptions, I18n.t('docs.offers.change_descriptions'), scope: :offer
    parameter :note, I18n.t('docs.offers.note'), scope: :offer

    parameter :cost, I18n.t('docs.offers.offer_specification.cost'), scope: [:offer, :offer_specifications_attributes, 0], required: true
    parameter :cost_nds, I18n.t('docs.offers.offer_specification.cost_nds'), scope: [:offer, :offer_specifications_attributes, 0], required: true
    parameter :specification_id, I18n.t('docs.offers.offer_specification.specification_id'), scope: [:offer, :offer_specifications_attributes, 0], required: true
    parameter :final_cost, I18n.t('docs.offers.offer_specification.final_cost'), scope: [:offer, :offer_specifications_attributes, 0], required: true
    parameter :final_cost_nds, I18n.t('docs.offers.offer_specification.final_cost_nds'), scope: [:offer, :offer_specifications_attributes, 0], required: true

    let(:lot_id) { tender.lots[0].id }
    let(:num) { 0 }
    let(:status_id) { Constants::OfferStatuses::WIN }
    let(:rebidded) { 0 }
    let(:maker) { 0 }
    let(:absent_auction) { nil }
    let(:conditions) { Faker::Lorem.sentence }
    let(:final_conditions) { Faker::Lorem.sentence }
    let(:change_descriptions) { nil }
    let(:note) { Faker::Lorem.sentence }

    let(:cost) { Faker::Number.decimal(2).to_f }
    let(:cost_nds) { cost }
    let(:final_cost) { cost }
    let(:final_cost_nds) { cost }
    let(:specification_id) { tender.lots[0].specifications[0].id }

    example 'Создание' do
      do_request
      expect(status).to eq(201)
    end
  end

  patch '/tenders/:tender_id/bidders/:bidder_id/offers/:id' do
    let!(:offer) { create(:offer, bidder_id: bidder_id,
                                  lot_id: lot_id,
                                  offer_specifications: [build(:offer_specification, specification_id: specification_id)]) }

    parameter :tender_id, I18n.t('docs.offers.tender_id'), required: true
    parameter :bidder_id, I18n.t('docs.offers.bidder_id'), required: true
    parameter :id, I18n.t('docs.offers.id'), required: true

    parameter :lot_id, I18n.t('docs.offers.lot_id'), scope: :offer, required: true
    parameter :status_id, I18n.t('docs.offers.status_id'), scope: :offer, required: true
    parameter :rebidded, I18n.t('docs.offers.rebidded'), scope: :offer
    parameter :maker, I18n.t('docs.offers.maker'), scope: :offer
    parameter :absent_auction, I18n.t('docs.offers.absent_auction'), scope: :offer
    parameter :conditions, I18n.t('docs.offers.conditions'), scope: :offer
    parameter :final_conditions, I18n.t('docs.offers.final_conditions'), scope: :offer
    parameter :change_descriptions, I18n.t('docs.offers.change_descriptions'), scope: :offer
    parameter :note, I18n.t('docs.offers.note'), scope: :offer

    parameter :id, I18n.t('docs.offers.offer_specification.id'), scope: [:offer, :offer_specifications_attributes, 0], required: true, method: :offer_specification_id
    parameter :cost, I18n.t('docs.offers.offer_specification.cost'), scope: [:offer, :offer_specifications_attributes, 0], required: true
    parameter :cost_nds, I18n.t('docs.offers.offer_specification.cost_nds'), scope: [:offer, :offer_specifications_attributes, 0], required: true
    parameter :specification_id, I18n.t('docs.offers.offer_specification.specification_id'), scope: [:offer, :offer_specifications_attributes, 0], required: true
    parameter :final_cost, I18n.t('docs.offers.offer_specification.final_cost'), scope: [:offer, :offer_specifications_attributes, 0], required: true
    parameter :final_cost_nds, I18n.t('docs.offers.offer_specification.final_cost_nds'), scope: [:offer, :offer_specifications_attributes, 0], required: true

    let(:id) { offer.id }
    let(:lot_id) { tender.lots[0].id }
    let(:num) { 0 }
    let(:status_id) { Constants::OfferStatuses::WIN }
    let(:rebidded) { 0 }
    let(:maker) { 0 }
    let(:absent_auction) { nil }
    let(:conditions) { Faker::Lorem.sentence }
    let(:final_conditions) { Faker::Lorem.sentence }
    let(:change_descriptions) { nil }
    let(:note) { Faker::Lorem.sentence }

    let(:offer_specification_id) { offer.offer_specifications[0].id }
    let(:cost) { Faker::Number.decimal(2).to_f }
    let(:cost_nds) { cost }
    let(:final_cost) { cost }
    let(:final_cost_nds) { cost }
    let(:specification_id) { tender.lots[0].specifications[0].id }

    example 'Корректировка' do
      do_request
      expect(status).to eq(204)
    end
  end

  delete '/tenders/:tender_id/bidders/:bidder_id/offers/:id' do
    let(:id) { create(:offer, bidder_id: bidder_id).id }

    parameter :tender_id, I18n.t('docs.offers.tender_id'), required: true
    parameter :bidder_id, I18n.t('docs.offers.bidder_id'), required: true
    parameter :id, I18n.t('docs.offers.id'), required: true

    example 'Удаление' do
      do_request
      expect(status).to eq(204)
    end
  end

  get '/tenders/:tender_id/bidders/:bidder_id/offers/:id' do

    let(:id) { create(:offer, bidder_id: bidder_id).id }

    parameter :tender_id, I18n.t('docs.offers.tender_id'), required: true
    parameter :bidder_id, I18n.t('docs.offers.bidder_id'), required: true
    parameter :id, I18n.t('docs.offers.id'), required: true

    example 'Просмотр' do
      do_request
      expect(status).to eq(200)
    end
  end
end

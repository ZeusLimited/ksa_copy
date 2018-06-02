require 'acceptance_helper'

resource 'Исполнение', acceptance: true do
  header 'Authorization', :auth_header
  let(:auth_header) { ActionController::HttpAuthentication::Basic.encode_credentials(user.login, password) }

  let(:user) { create(:user_user, password: password) }
  let(:password) { Faker::Internet.password(8, 12) }

  get '/tenders/:id/tender_documents' do
    let!(:tender) { create(:tender, :with_files) }
    let!(:lot) { create(:lot, tender_id: tender.id) }
    let!(:bidder) { create(:bidder, :with_files, tender_id: tender.id) }
    let!(:offer) { create(:offer, :win, lot_id: lot.id, bidder_id: bidder.id) }
    let!(:contract) { create(:contract, :with_files, offer_id: offer.id, lot_id: lot.id) }
    let(:id) { tender.id }

    parameter :id, required: true

    example 'Документация к закупочной процедуре' do
      do_request
      expect(status).to eq(200)
    end
  end
end

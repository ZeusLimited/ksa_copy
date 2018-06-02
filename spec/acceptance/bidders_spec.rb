require 'acceptance_helper'

resource 'Исполнение', acceptance: true do
  header 'Authorization', :auth_header
  let(:auth_header) { ActionController::HttpAuthentication::Basic.encode_credentials(user.login, password) }

  let(:user) { create(:user_user, password: password) }
  let(:password) { Faker::Internet.password(8, 12) }

  let(:tender) { create(:tender) }
  let(:tender_id) { tender.id }

  get '/tenders/:tender_id/bidders' do
    parameter :tender_id, required: true

    before do
      create_list(:bidder, 3, tender_id: tender_id)
    end

    example 'Просмотр списка участников' do
      do_request
      expect(status).to eq(200)
    end
  end

  get '/tenders/:tender_id/bidders/:id' do
    parameter :tender_id, required: true
    parameter :id, required: true

    let(:id) { create(:bidder, :with_files, :with_covers, tender_id: tender_id).id }

    example 'Просмотр участника' do
      do_request
      expect(status).to eq(200)
    end
  end
end

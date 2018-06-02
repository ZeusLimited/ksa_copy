require 'acceptance_helper'

resource 'Исполнение', acceptance: true do
  header 'Authorization', :auth_header
  let(:auth_header) { ActionController::HttpAuthentication::Basic.encode_credentials(user.login, password) }

  let(:user) { create(:user_user, password: password) }
  let(:password) { Faker::Internet.password(8, 12) }

  let(:tender) { create(:tender) }
  let(:tender_id) { tender.id }  
  
  get '/tenders/:tender_id/winner_protocols' do

    parameter :tender_id, required: true

    example 'Список протоколов выбора победителя' do
      do_request
      expect(status).to eq(200)
    end
  end

  get '/tenders/:tender_id/winner_protocols/:id' do

    let(:id) { create(:lot_with_contract, tender_id: tender_id).winner_protocol_id }

    parameter :tender_id, required: true
    parameter :id, required: true

    example 'Просмотр протокола выбора победителя' do
      do_request
      expect(status).to eq(200)
    end
  end
end

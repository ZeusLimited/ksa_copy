# frozen_string_literal: true

require 'acceptance_helper'

resource 'Справочники: Контрагенты', acceptance: true do
  header 'Authorization', :auth_header
  let(:auth_header) { ActionController::HttpAuthentication::Basic.encode_credentials(user.login, password) }

  let(:user) { create(:user_user, password: password) }
  let(:password) { Faker::Internet.password(8, 12) }

  let(:contractor) { create(:contractor) }
  let(:q) { contractor.name }
  let(:id) { contractor.id }

  get '/contractors' do
    parameter :q

    example 'Список контрагентов' do
      do_request
      expect(status).to eq(200)
    end
  end

  get '/contractors/:id' do
    parameter :id, required: true

    example 'Получение контрагента по id' do
      do_request
      expect(status).to eq(200)
    end
  end
end

# frozen_string_literal: true

require 'acceptance_helper'

resource 'Планирование', acceptance: true do
  header 'Authorization', :auth_header
  let(:auth_header) { ActionController::HttpAuthentication::Basic.encode_credentials(user.login, password) }

  let(:user) { create(:user_moderator, password: password) }
  let(:password) { Faker::Internet.password(8, 12) }

  patch '/eis_plan_lots/:id' do
    let(:plan_lot) { create(:plan_lot_with_specs) }

    let(:id) { eis.id }
    let(:num) { Faker::Number.number(7) }

    parameter :id, required: true
    parameter :num

    let!(:eis) { create(:eis_plan_lot, plan_lot_guid: plan_lot.guid, year: plan_lot.announce_date.year) }

    example 'Обновление номера на ЕИС' do
      do_request
      expect(status).to eq 204
    end
  end
end

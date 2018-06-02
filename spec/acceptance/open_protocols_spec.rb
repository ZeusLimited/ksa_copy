require 'acceptance_helper'

resource 'Протокол вскрытия', acceptance: true do
  header 'Authorization', :auth_header
  let(:auth_header) { ActionController::HttpAuthentication::Basic.encode_credentials(user.login, password) }

  let(:user) { create(:user_user, password: password) }
  let(:password) { Faker::Internet.password(8, 12) }

  post '/tenders/:tender_id/open_protocols' do
    parameter :tender_id, I18n.t('docs.open_protocols.tender_id'), required: true

    parameter :clerk_id, I18n.t('docs.open_protocols.clerk_id'), scope: :open_protocol, required: true
    parameter :location, I18n.t('docs.open_protocols.location'), scope: :open_protocol, required: true
    parameter :num, I18n.t('docs.open_protocols.num'), scope: :open_protocol, required: true
    parameter :open_date, I18n.t('docs.open_protocols.open_date'), scope: :open_protocol, required: true
    parameter :resolve, I18n.t('docs.open_protocols.resolve'), scope: :open_protocol, required: true
    parameter :sign_city, I18n.t('docs.open_protocols.sign_city'), scope: :open_protocol, required: true
    parameter :sign_date, I18n.t('docs.open_protocols.sign_date'), scope: :open_protocol, required: true
    parameter :commission_id, I18n.t('docs.open_protocols.commission_id'), scope: :open_protocol, required: true

    parameter :status_id, I18n.t('docs.open_protocols.open_protocol_present_members.status_id'),
              scope: [:open_protocol, :open_protocol_present_members_attributes, [0]]
    parameter :user_id, I18n.t('docs.open_protocols.open_protocol_present_members.user_id'),
              scope: [:open_protocol, :open_protocol_present_members_attributes, [0]]
    parameter :status_name, I18n.t('docs.open_protocols.open_protocol_present_members.status_name'),
              scope: [:open_protocol, :open_protocol_present_members_attributes, [0]]
    parameter :enable, I18n.t('docs.open_protocols.open_protocol_present_members.enable'),
              scope: [:open_protocol, :open_protocol_present_members_attributes, [0]]

    let!(:tender) { create(:tender_with_public_lot) }
    let(:commission) { create(:commission_with_users) }

    let(:tender_id) { tender.id }

    let(:clerk_id) { commission.commission_users.clerks.first.user_id }
    let(:location) { Faker::Lorem.characters(10) }
    let(:num) { Faker::Number.number(4) }
    let(:open_date) { Faker::Date.forward(1) }
    let(:resolve) { Faker::Lorem.sentence }
    let(:sign_city) { Faker::Lorem.characters(10) }
    let(:sign_date) { Faker::Date.forward(1) }
    let(:commission_id) { commission.id }

    let(:status_id) { commission.commission_users.clerks.first.status }
    let(:enable) { '1' }
    let(:user_id) { commission.commission_users.clerks.first.user_id }

    let(:fail_params) do
      {
        clerk_id: nil,
        location: nil,
        num: nil,
        open_date: nil,
        resolve: nil,
        sign_city: nil,
        sign_date: nil,
        commission_id: nil
      }
    end

    example 'Создание протокола вскрытия' do
      do_request
      expect(status).to eq(200)
    end

    example 'Создание протокола вскрытия - ошибка' do
      do_request(open_protocol: fail_params)
      expect(status).to eq(422)
    end
  end
end

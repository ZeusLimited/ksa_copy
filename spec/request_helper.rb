# frozen_string_literal: true

module Request
  module AuthHelpers
    def auth_headers(user = nil, password = Faker::Internet.password(8, 12))
      user ||= create(:user_user, password: password)
      {
        'Authorization': ActionController::HttpAuthentication::Basic.encode_credentials(user.login, password),
      }
    end
  end
end

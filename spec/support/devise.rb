# This support package contains modules for authenticaiting
# devise users for request specs.

# This module authenticates users for request specs.#
module ValidUserRequestHelper
  def sign_in_as_admin
    @user = FactoryGirl.create :user_admin
    post_via_redirect user_session_path, 'user[login]' => @user.login, 'user[password]' => @user.password
  end
end

# Configure these to modules as helpers in the appropriate tests.
RSpec.configure do |config|
  config.include ValidUserRequestHelper, type: :request
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :view
end

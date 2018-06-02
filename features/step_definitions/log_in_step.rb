Given /^I logged in as (.*)$/ do |role|
  user = FactoryGirl.create("user_#{role}".to_sym, password: (password = 'password'), password_confirmation: password)
  steps %Q{
    Given I am on the new user session page
    When I fill in "user_login" with "#{user.login}"
     And I fill in "user_password" with "#{password}"
     And I press "log_in"
    Then I should see "Добро пожаловать."
  }
  @current_user ||= user
end

Given /^I have logged in as (.*)$/ do |role|
  steps %Q{
    Given there is a user #{role} with the login "MyString" and the password "xyz12" and password_confirmation "xyz12"
     And I am on the new user session page
    When I fill in "user_login" with "MyString"
     And I fill in "user_password" with "xyz12"
     And I press "log_in"
    Then I should see "Добро пожаловать."
  }
end

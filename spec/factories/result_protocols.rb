# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :result_protocol do
    tender
    sequence(:num) { |n| "Num #{n}" }
    sign_date "2015-01-28"
    sign_city "MyString"
  end
end

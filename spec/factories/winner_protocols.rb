# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :winner_protocol do
    tender
    violation_reason Faker::Lorem.characters(20)
    sequence(:num) { |n| "Num #{n}" }
    confirm_date "2014-03-13"
  end
end

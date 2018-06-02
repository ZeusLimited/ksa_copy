# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :plan_lot_non_execution do
    reason "MyText"
    user
  end
end

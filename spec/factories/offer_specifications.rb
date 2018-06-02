# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :offer_specification do
    offer_id 1
    specification_id 1
    cost Faker::Number.decimal(6, 2)
    cost_nds Faker::Number.decimal(6, 2)
    final_cost Faker::Number.decimal(6, 2)
    final_cost_nds Faker::Number.decimal(6, 2)
  end
end

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :contract_specification do
    contract_id 1
    specification_id 1
    cost "9.99"
    cost_nds "9.99"
  end
end

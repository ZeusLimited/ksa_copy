# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :contract_amount do
    contract_specification_id 1
    year 2014
    amount_finance "9.99"
    amount_finance_nds "9.99"
  end
end

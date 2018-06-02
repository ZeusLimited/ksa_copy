# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :contract_termination do
    contract_id 1
    type_id ContractTerminationTypes::AGREEMENT
    cancel_date "2014-03-06"
    unexec_cost "9.99"
    unexec_cost_money "9.99"

    trait(:agreement) { type_id ContractTerminationTypes::AGREEMENT }
    trait(:court) { type_id ContractTerminationTypes::COURT }
    trait(:refusal) { type_id ContractTerminationTypes::REFUSAL }
  end
end

include Constants

FactoryGirl.define do
  factory :contract do
    num Faker::Number.number(4)
    confirm_date Faker::Date.between(Date.today, 3.days.from_now)
    delivery_date_begin Faker::Date.between(3.days.from_now, 6.days.from_now)
    delivery_date_end Faker::Date.between(7.days.from_now, 14.days.from_now)
    non_delivery_reason Faker::Lorem.sentence
    type_id ContractTypes::BASIC

    trait(:basic) { type_id ContractTypes::BASIC }
    trait(:reduction) { type_id ContractTypes::REDUCTION }

    trait(:with_files) do
      after(:create) do |c|
        create(:contract_file, contract_id: c.id, tender_file: create(:tender_file, :contract))
      end
    end

    factory :contract_with_spec do
      after(:create) do |contract, _evaluator|
        first_spec = contract.lot.specifications[0]
        create(:contract_specification, contract: contract, specification: first_spec)
      end
    end
    factory :contract_with_termination do
      after(:create) do |contract, _evaluator|
        create(:contract_termination, contract: contract)
      end
    end
  end
end

FactoryGirl.define do
  factory :contract_file do
    contract_id 1
    tender_file_id 1
    file_type_id TenderFileType::CONTRACT
    note Faker::Lorem.sentence
  end
end

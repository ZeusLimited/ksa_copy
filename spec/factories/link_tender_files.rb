# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :link_tender_file do
    tender_id 1
    association :tender_file, factory: [:tender_file, :tender]
    note Faker::Lorem.sentence
    file_type_id 1

    trait(:zd) { file_type_id 25_001 }
  end
end

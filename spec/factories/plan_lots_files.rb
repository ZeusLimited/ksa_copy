# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :plan_lots_file do
    plan_lot_id 1
    tender_file_id 1
    note Faker::Lorem.sentence
    file_type_id 17003

    trait(:nmcd) { Constants::FileType::NMCD }
  end
end

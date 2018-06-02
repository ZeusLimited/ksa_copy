# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :bidder_file do
    note Faker::Lorem.sentence
    tender_file_id 1
    bidder_id 1
  end
end

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :cover do
    bidder_id 1
    register_time "2013-11-28"
    register_num Faker::Number.number(4)
    type_id 1
    delegate Faker::Name.name
    provision Faker::Lorem.word
  end
end

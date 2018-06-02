FactoryGirl.define do
  factory :tender_dates_for_type do
    days Faker::Number.number(1)
    tender_type_id 10011
  end
end

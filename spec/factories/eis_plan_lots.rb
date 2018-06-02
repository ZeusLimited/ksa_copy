FactoryGirl.define do
  factory :eis_plan_lot do
    plan_lot_guid { SecureRandom.uuid }
    year Time.current.year
    num Faker::Number.number(6)
  end
end

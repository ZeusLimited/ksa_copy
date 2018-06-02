FactoryGirl.define do
  factory :contractor do
    name Faker::Company.unique.name
    fullname { name }
    ownership_id Faker::Number.number(1)
    status "orig"
    form "foreign"
    legal_addr Faker::Address.street_address
    is_sme false
    user { create(:user) }

    trait(:active) { status "active" }
  end
end

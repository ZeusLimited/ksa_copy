FactoryGirl.define do
  factory :offer do
    bidder
    change_descriptions Faker::Lorem.sentence
    conditions Faker::Lorem.sentence
    final_conditions Faker::Lorem.sentence
    is_winer false
    lot { create(:lot_with_spec) }
    note Faker::Lorem.sentence
    num 0
    type_id 1
    version 0
    status_id OfferStatuses::NEW

    trait(:new) { status_id OfferStatuses::NEW }
    trait(:receive) { status_id OfferStatuses::RECEIVE }
    trait(:reject) { status_id OfferStatuses::REJECT }
    trait(:win) { status_id OfferStatuses::WIN }
    trait(:pickup) { type_id OfferTypes::PICKUP }
  end
end

def create_nested_lot(lot, objects)
  lot.plan_lot.plan_specifications.each do |ps|
    lot.specifications << build(:specification, plan_specification_id: ps.id)
  end
  spec = lot.specifications[0]
  bidder = create(:bidder, tender_id: lot.tender_id) if objects[:bidder]
  if objects[:offer]
    offer = create(:offer, :win, bidder: bidder, lot: lot)
    create(:offer_specification, offer: offer, specification: spec)
  end
  if objects[:contract]
    contract = create(:contract, lot: lot, offer: offer)
    cs = create(:contract_specification, contract: contract, specification: spec)
    create(:contract_amount, contract_specification: cs)
  end
  if objects[:contract_termination]
    create(:contract_termination, contract: contract)
  end
  if objects[:winner_protocol]
    create(
      :winner_protocol,
      tender_id: lot.tender_id,
      winner_protocol_lots: [build(:winner_protocol_lot, :winner, lot: lot)]
    )
  end
end

FactoryGirl.define do
  factory :lot do
    num 1
    name Faker::Lorem.sentence
    tender
    rebid_type_id 1
    status_id LotStatus::NEW
    subject_type_id SubjectType::MATERIALS
    guarantie_cost Faker::Number.decimal(6, 2)
    non_public_reason Faker::Lorem.sentence
    num_plan_eis Faker::Lorem.characters(10)

    plan_lot { create(:plan_lot_with_specs, :agreement) }
    root_customer { FactoryGirl.create(:department) }

    gkpz_year { plan_lot.gkpz_year }

    trait(:new) { status_id LotStatus::NEW }
    trait(:public) { status_id LotStatus::PUBLIC }
    trait(:open) { status_id LotStatus::OPEN }
    trait(:review) { status_id LotStatus::REVIEW }
    trait(:review_confirm) { status_id LotStatus::REVIEW_CONFIRM }
    trait(:reopen) { status_id LotStatus::REOPEN }
    trait(:sw) { status_id LotStatus::SW }
    trait(:sw_confirm) { status_id LotStatus::SW_CONFIRM }
    trait(:winner) { status_id LotStatus::WINNER }
    trait(:rp_sign) { status_id LotStatus::RP_SIGN }
    trait(:contract) { status_id LotStatus::CONTRACT }
    trait(:fail) { status_id LotStatus::FAIL }
    trait(:cancel) { status_id LotStatus::CANCEL }
    trait(:with_plan_lot_with_order) { plan_lot { create(:plan_lot_with_order, :agreement) } }

    after(:build) do |lot|
      lot.plan_lot_guid = lot.plan_lot.guid
    end

    factory :lot_with_spec do
      after(:build) do |lot|
        lot.plan_lot.plan_specifications.each do |ps|
          lot.specifications << build(:specification, plan_specification_id: ps.id)
        end
      end
    end

    factory :lot_with_order do
      plan_lot { create(:plan_lot_with_order, :agreement) }
      order { plan_lot.orders.last }
    end

    factory :lot_with_contract do
      after(:create) do |lot|
        create_nested_lot(lot, bidder: true, offer: true, winner_protocol: true, contract: true)
      end
    end

    factory :lot_with_review_protocol do
      after(:create) do |lot|
        create_nested_lot(lot, bidder: true, offer: true, review_protocol: true)
      end
    end

    factory :lot_with_contract_termination do
      after(:create) do |lot|
        create_nested_lot(lot, bidder: true, offer: true, offer_specification: true,
          winner_protocol: true, contract: true, contract_termination: true)
      end
    end
  end
end

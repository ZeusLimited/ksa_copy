def create_nested_tender(tender, lotstatus, objects)
  lot = create(:lot_with_spec, lotstatus, tender: tender)
  tender.lots << lot
  spec = lot.specifications[0]
  bidder = create(:bidder, tender: tender) if objects[:bidder]
  if objects[:offer]
    offer = create(:offer, :win, bidder: bidder, lot: lot)
    create(:offer_specification, offer: offer, specification: spec)
  end
  if objects[:contract]
    contract = create(:contract, lot: lot, offer: offer)
    cs = create(:contract_specification, contract: contract, specification: spec)
    create(:contract_amount, contract_specification: cs)
  end
  if objects[:review_protocol]
    create(:review_protocol, tender: tender, review_lots: [build(:review_lot, lot: lot, rebid: "1")])
  end
  if objects[:rebid_protocol]
    create(:rebid_protocol, tender: tender, rebid_date: lot.review_lots[0].rebid_date, lots: [lot])
  end
  if objects[:winner_protocol]
    create(
      :winner_protocol,
      tender: tender,
      winner_protocol_lots: [build(:winner_protocol_lot, :winner, lot: lot)]
    )
  end
  create(:open_protocol, tender: tender) if objects[:open_protocol]
end

FactoryGirl.define do
  factory :tender do
    num Faker::Number.number(4)
    name Faker::Lorem.sentence
    tender_type_id TenderTypes::OOK
    tender_type_explanations Faker::Lorem.sentence
    etp_address_id EtpAddress::B2B_ENERGO
    department
    announce_date Faker::Date.between(80.business_days.ago, 70.business_days.ago)
    announce_place Faker::Lorem.sentence
    bid_date Faker::Time.between(50.business_days.ago, 41.business_days.ago)
    bid_place Faker::Lorem.sentence
    user
    oos_num Faker::Number.number(12)
    oos_id Faker::Number.number(7)
    etp_num Faker::Number.number(6)
    order_num Faker::Number.number(4)
    order_date Faker::Date.between(90.business_days.ago, 81.business_days.ago)
    contact_id 1
    hidden_offer Faker::Boolean.boolean
    confirm_place Faker::Lorem.sentence
    explanation_period 1
    paper_copies Faker::Number.number(1)
    digit_copies Faker::Number.number(1)
    life_offer Faker::Number.number(1)
    review_place Faker::Lorem.sentence
    review_date Faker::Date.between(40.business_days.ago, 31.business_days.ago)
    summary_place Faker::Lorem.sentence
    summary_date Faker::Date.between(30.business_days.ago, 20.business_days.ago)
    is_sertification Faker::Boolean.boolean
    is_guarantie true
    guarantie_offer Faker::Lorem.sentence
    guarantie_date_begin Faker::Date.between(90.business_days.ago, 81.business_days.ago)
    guarantie_date_end Faker::Date.between(40.business_days.ago, 30.business_days.ago)
    guarantie_making_money Faker::Lorem.sentence
    guarantie_recvisits Faker::Lorem.sentence
    guarant_criterions Faker::Lorem.sentence
    is_multipart Faker::Boolean.boolean
    alternate_offer 1
    alternate_offer_aspects Faker::Lorem.sentence
    maturity Faker::Lorem.sentence
    is_prepayment false
    prepayment_cost 1.5
    prepayment_percent 1.5
    prepayment_aspects Faker::Lorem.sentence
    prepayment_period_begin Faker::Lorem.sentence
    prepayment_period_end Faker::Lorem.sentence
    project_type_id 1
    project_text Faker::Lorem.sentence
    provide_td Faker::Lorem.sentence
    preferences Faker::Lorem.sentence
    other_terms Faker::Lorem.sentence
    contract_period 1
    prepare_offer Faker::Lorem.sentence
    provide_offer Faker::Lorem.sentence
    is_gencontractor Faker::Boolean.boolean
    contract_guarantie Faker::Lorem.sentence
    is_simple_production Faker::Boolean.boolean
    reason_for_replace Faker::Lorem.sentence
    offer_reception_place Faker::Lorem.sentence
    is_rebid Faker::Boolean.boolean
    commission
    local_time_zone { create(:local_time_zone) }
    contract_period_type Faker::Boolean.boolean
    official_site_num Faker::Number.number(10)
    b2b_classifiers []

    trait(:ook) { tender_type_id TenderTypes::OOK }
    trait(:ozp) { tender_type_id TenderTypes::OZP }
    trait(:po) { tender_type_id TenderTypes::PO }
    trait(:only_source) do
      tender_type_id TenderTypes::ONLY_SOURCE
      etp_address_id EtpAddress::NOT_ETP
    end
    trait(:unregulated) do
      tender_type_id TenderTypes::UNREGULATED
      etp_address_id EtpAddress::NOT_ETP
      review_place nil
      review_date nil
      summary_place nil
      summary_date nil
    end

    trait(:etp_b2b) { etp_address_id EtpAddress::B2B_ENERGO }

    trait(:with_files) do
      transient do
        files_count 3
      end

      after(:build) do |tender, evaluator|
        tender.link_tender_files = build_list(:link_tender_file, evaluator.files_count, :zd)
      end
    end

    factory :tender_with_lots do
      transient do
        lots_count 3
      end

      after(:create) do |tender, evaluator|
        create_list(:lot_with_spec, evaluator.lots_count, tender: tender)
      end
    end

    factory :tender_with_new_lot do
      after(:create) do |tender|
        create_nested_tender(tender, :new, {})
      end
    end

    factory :tender_with_public_lot do
      after(:create) do |tender|
        create_nested_tender(tender, :public, {})
      end
    end

    factory :tender_with_winner_lot do
      after(:create) do |tender|
        create_nested_tender(tender, :winner, bidder: true, offer: true, winner_protocol: true)
      end
    end

    factory :tender_with_fail_lot do
      after(:create) do |tender|
        create_nested_tender(tender, :fail, bidder: true, offer: true, winner_protocol: true)
      end
    end

    factory :tender_with_open_lot do
      after(:create) do |tender|
        create_nested_tender(tender, :open, bidder: true, offer: true, open_protocol: true)
      end
    end

    factory :tender_with_rp_sign_lot do
      after(:create) do |tender|
        create_nested_tender(tender, :rp_sign, bidder: true, offer: true, winner_protocol: true)
      end
    end

    factory :tender_with_review_lot do
      after(:create) do |tender|
        create_nested_tender(tender, :review, bidder: true, offer: true, review_protocol: true)
      end
    end

    factory :tender_with_review_confirm_lot do
      after(:create) do |tender|
        create_nested_tender(tender, :review_confirm, bidder: true, offer: true, review_protocol: true)
      end
    end

    factory :tender_with_reopen_lot do
      after(:create) do |tender|
        create_nested_tender(tender, :reopen, bidder: true, offer: true, review_protocol: true, rebid_protocol: true)
      end
    end

    factory :tender_with_contract_lot do
      after(:create) do |tender|
        create_nested_tender(tender, :contract, bidder: true, offer: true, winner_protocol: true, contract: true)
      end
    end
  end
end

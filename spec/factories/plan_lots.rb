def create_nested_plan_lot(pl)
  ps = create(:plan_specification, plan_lot: pl, customer: pl.root_customer)
  create(:plan_spec_amount, plan_specification: ps)
  create(:fias_plan_specification, plan_specification: ps)
end

FactoryGirl.define do
  factory :plan_lot do
    gkpz_year 2016
    sequence(:num_tender)
    num_lot 1
    lot_name Faker::Lorem.sentence
    tender_type_explanations Faker::Lorem.sentence
    announce_date { "#{gkpz_year}-01-01" }
    explanations_doc Faker::Lorem.sentence
    point_clause Faker::Lorem.sentence
    status_id PlanLotStatus::NEW
    order1352_id Order1352::NOT_SELECT

    # associations
    association :root_customer, factory: :department
    department
    user
    etp_address_id EtpAddress::NOT_ETP
    subject_type_id SubjectType::MATERIALS
    tender_type_id TenderTypes::OOK
    commission

    association :regulation_item, factory: :regulation_item_with_tender_types

    trait(:new) { status_id PlanLotStatus::NEW }
    trait(:under_consideration) { status_id PlanLotStatus::UNDER_CONSIDERATION }
    trait(:agreement) do
      status_id PlanLotStatus::AGREEMENT
      protocol { build(:protocol, :level1_kk) }
    end
    trait(:canceled) do
      status_id PlanLotStatus::CANCELED
      protocol { build(:protocol, :level1_kk) }
    end
    trait(:pre_confirm_sd) { status_id PlanLotStatus::PRE_CONFIRM_SD }
    trait(:confirm_sd) { status_id PlanLotStatus::CONFIRM_SD }
    trait(:excluded_sd) { status_id PlanLotStatus::EXCLUDED_SD }
    trait(:considered) { status_id PlanLotStatus::CONSIDERED }
    trait(:import) { status_id PlanLotStatus::IMPORT }
    trait(:organizer_eq_customer) do
      department { root_customer }
    end

    trait(:sme) do
      sme_type_id SmeTypes::SME
      order1352_id Order1352::SELECT
    end

    trait(:innovation) do
      tender_type_id nil
      etp_address_id nil
      department_id nil
      include_ipivp true
    end
    trait(:version2) { version 2 }
    trait(:single_source) do
      tender_type_id TenderTypes::ONLY_SOURCE
      commission_id nil
    end
    trait(:unregulated) { tender_type_id TenderTypes::UNREGULATED }
    trait(:zpp) { tender_type_id TenderTypes::ZPP }
    trait(:simple) { tender_type_id TenderTypes::SIMPLE }

    trait(:frame) { tender_type_id TenderTypes::ZRK }


    trait(:ttype_po) do
      tender_type_id TenderTypes::PO

      after(:build) do |pl, _e|
        pl.plan_annual_limits << build(:plan_annual_limit)
      end
    end

    trait :pastselection do
      tender_type_id TenderTypes::ZZC

      after :build do |pl, _e|
        pl.preselection_guid = create(:plan_lot, :ttype_po).guid
      end
    end

    trait(:etp_b2b) { etp_address_id EtpAddress::B2B_ENERGO }
    trait(:non_etp) { etp_address_id EtpAddress::NOT_ETP }

    trait(:own) do
      department_id { root_customer_id }
      commission { create(:commission, :level1_kk) }
    end

    transient { contractors_count 3 }

    after(:build) do |pl, evaluator|
      unless pl.preselection_guid
        evaluator.contractors_count.times do
          pl.plan_lot_contractors << build(:plan_lot_contractor, contractor: create(:contractor))
        end
      end
    end

    factory :plan_lot_with_specs do
      after(:create) do |plan_lot|
        create_nested_plan_lot(plan_lot)
        plan_lot.plan_specifications.reload
      end
    end

    factory :plan_lot_with_order do
      after(:create) do |plan_lot|
        plan_lot.orders << create(:order)
      end
    end

    factory :plan_lot_with_approved_order_and_specs do
      after(:create) do |plan_lot|
        create_nested_plan_lot(plan_lot)
        plan_lot.plan_specifications.reload
        plan_lot.orders << create(:order, :approved)
      end
    end
  end
end

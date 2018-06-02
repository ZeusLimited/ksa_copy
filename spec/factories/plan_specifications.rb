FactoryGirl.define do
  factory :plan_specification do
    guid SecureRandom.random_bytes(16)
    num_spec 1
    name Faker::Lorem.sentence
    qty 1
    cost { plan_lot && plan_lot.tender_type_id == TenderTypes::PO ? 0 : 1000 }
    cost_nds { plan_lot && plan_lot.tender_type_id == TenderTypes::PO ? 0 : 1180 }
    # cost_doc Dictionary.cost_docs.first.try(:name)
    unit
    association :okdp, factory: :okdp_type_new
    association :okved, factory: :okved_new
    direction_id 1
    product_type_id 1
    financing_id Financing::COST_PRICE
    bp_state_id 1
    # customer { FactoryGirl.create(:department) }
    association :customer, factory: :department
    association :consumer, factory: [:department, :child]
    # consumer { FactoryGirl.create(:department) }
    monitor_service_id 1
    invest_project_id 1
    delivery_date_begin { plan_lot ? "#{plan_lot.gkpz_year}-12-20" : "2016-12-20" }
    delivery_date_end { plan_lot ? "#{plan_lot.gkpz_year}-12-20" : "2016-12-20" }
    bp_item Faker::Lorem.sentence
    requirements Faker::Lorem.sentence
    potential_participants Faker::Lorem.sentence
    curator Faker::Name.name
    tech_curator Faker::Name.name
    note Faker::Lorem.sentence

    production_units { [create(:department, :child)] }
    trait(:cost_100) { cost 100_000_000 }
    trait(:cost_nds_100) { cost 118_000_000 }
    trait(:cost_300) { cost 300_000_000 }
    trait(:cost_nds_300) { cost 318_000_000 }
    trait(:cost_500) { cost 500_000_000 }
    trait(:cost_nds_500) { cost 518_000_000 }


    factory :plan_specification_with_plan_spec_amounts do
      transient do
        psa_count 1
      end
      after(:create) do |ps, evaluator|
        create_list(:plan_spec_amount, evaluator.psa_count, plan_specification: ps)
      end
    end

    factory :plan_specification_with_plan_spec_amounts_fias_plan_specification do
      transient do
        psa_count 1
      end
      after(:create) do |ps, evaluator|
        create_list(:plan_spec_amount, evaluator.psa_count, plan_specification: ps)
        create_list(:fias_plan_specification, evaluator.psa_count, plan_specification: ps)
      end
    end
  end
end

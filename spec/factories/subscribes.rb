FactoryGirl.define do
  factory :subscribe do
    user_id 1
    plan_lot_guid ""
    plan_structure "MyText"
    fact_structure "MyText"
    # plan_lot

    factory :subscribe_with_plan_struct do
      after(:build) do |s|
        s.plan_structure = s.plan_lot.to_struct
      end
    end
  end
end

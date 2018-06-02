# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :specification do
    num 1
    name "MyString"
    qty 1
    cost 1.5
    cost_nds 1.5
    is_public_cost false
    unit_id 1
    # lot_id 1
    # plan_specification_id 1
    direction
    financing_id Financing::COST_PRICE
    product_type_id 1
    association :customer, factory: :department
    consumer { customer }
    invest_project_id 1

    after(:build) do |s|
      s.plan_specification_guid = s.plan_specification&.guid
    end
  end
end

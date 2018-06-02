# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :department do
    sequence(:name) { |n| "departmenrt#{n}" }
    sequence(:position) { |n| n }
    sequence(:fullname) { |n| "departmenrt#{n}" }
    inn "2801133630"
    kpp "272401001"
    ownership_id 2
    is_customer true
    is_organizer true
    eis223_limit Faker::Number.number(5)

    trait(:consumer) { is_consumer true }
    trait(:child) do
      inn nil
      kpp nil
      ownership_id nil
      parent_dept_id { create(:department).id }
      is_child true
    end
  end
end

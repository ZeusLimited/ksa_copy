include Constants

FactoryGirl.define do
  factory :commission do
    name Faker::Lorem.sentence
    department
    commission_type_id CommissionType::CZK
    is_actual 1

    trait(:level1_kk) { commission_type_id CommissionType::LEVEL1_KK }
    trait(:level2_kk) { commission_type_id CommissionType::LEVEL2_KK }
    trait(:szk) { commission_type_id CommissionType::SZK }
    trait(:czk) { commission_type_id CommissionType::CZK }
    trait(:sd) { commission_type_id CommissionType::SD }

    factory :commission_with_users do
      after(:create) do |commission|
        create(:commission_user, :boss, commission: commission)
        create(:commission_user, :sub_boss, commission: commission)
        create(:commission_user, :clerk, commission: commission)
        create(:commission_user, :member, commission: commission)
        create(:commission_user, :member, commission: commission)
      end
    end
  end
end

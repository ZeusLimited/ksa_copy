# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :role do
    name "MyString"
    name_ru "MyString"

    trait :admin do
      id 6
      name "Admin"
      name_ru "Admin"
    end

    trait :contractor_boss do
      id 13
      name "ContractorBoss"
      name_ru "ContractorBoss"
    end

    trait :moderator do
      id 7
      name "Moderator"
      name_ru "Moderator"
    end

    trait :user_boss do
      id 8
      name "UserBoss"
      name_ru "UserBoss"
    end

    trait :user do
      id 9
      name "User"
      name_ru "User"
    end

    trait :view do
      id 10
      name "View"
      name_ru "View"
    end
  end
end

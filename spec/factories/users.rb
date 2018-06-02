FactoryGirl.define do
  factory :user do
    sequence(:login) { |n| "Test User #{n}" }
    email Faker::Internet.email
    surname 'Surname'
    name 'Name'
    patronymic 'Patronymic'
    user_job 'Job'
    phone_public '(4212)264500'
    phone_cell '89141000000'
    gender 'male'

    password 'changeme'
    password_confirmation { password }

    approved true

    association :department
    # association :roles
    factory :user_admin do
      after(:create) do |user|
        user.roles << FactoryGirl.create(:role, :admin)
      end
    end

    factory :user_moderator do
      after(:create) do |user|
        user.roles << FactoryGirl.create(:role, :moderator)
      end
    end

    factory :user_boss do
      after(:create) do |user|
        user.roles << FactoryGirl.create(:role, :user_boss)
      end
    end

    factory :user_user do
      after(:create) do |user|
        user.roles << FactoryGirl.create(:role, :user)
      end
    end

    factory :user_contractor_boss do
      after(:create) do |user|
        user.roles << FactoryGirl.create(:role, :contractor_boss)
      end
    end

    factory :user_view do
      after(:build) do |user|
        user.roles << build(:role, :view)
      end
    end
  end
end

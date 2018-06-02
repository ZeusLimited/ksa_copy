FactoryGirl.define do
  factory :order do
    sequence(:num) { |n| "#{n}" }
    sequence(:receiving_date) { |n| "#{Time.now + n.day}" }
    agreement_date nil
    association :received_from, factory: :user
    association :agreed_by, factory: :user

    trait(:approved) do
      agreement_date { receiving_date }
    end

    trait(:without_users) do
      received_from nil
      agreed_by nil
      agreement_date { receiving_date }
    end
  end
end

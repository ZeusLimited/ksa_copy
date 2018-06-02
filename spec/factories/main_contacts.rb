FactoryGirl.define do
  factory :main_contact do
    role "developer"
    sequence(:position)
    user
  end
end

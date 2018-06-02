# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :assignment do
    user_id 1
    role_id 1
    department_id 2
  end
end

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :task do
    description "MyText"
    priority 1
    task_status_id 1
    task_comment "MyText"

    association :user
    association :task_status
  end
end

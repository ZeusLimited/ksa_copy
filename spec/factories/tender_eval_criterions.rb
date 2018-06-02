# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tender_eval_criterion do
    num 1
    position 1
    name "MyString"
    value 1
    tender_id 1
  end
end

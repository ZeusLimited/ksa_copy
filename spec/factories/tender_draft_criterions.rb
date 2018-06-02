# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tender_draft_criterion do
    num 1
    name "MyText"
    tender_id 1
  end
end

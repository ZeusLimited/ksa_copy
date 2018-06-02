# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :draft_opinion do
    criterion_id 1
    expert_id 1
    offer_id 1
    vote nil
    description "MyText"
  end
end

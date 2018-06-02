# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :plan_spec_amount do
    # association :plan_specification
    year 2013
    amount_mastery 1000
    amount_mastery_nds 1180
    amount_finance 1000
    amount_finance_nds 1180
  end
end

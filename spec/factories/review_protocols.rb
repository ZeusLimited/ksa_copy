# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :review_protocol do
    tender_id 1
    sequence(:num) { |n| "Num #{n}" }
    confirm_date "2014-03-13"
    # lots { [FactoryGirl.create(:lot)] }
  end
end

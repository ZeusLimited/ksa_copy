# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :doc_taker do
    contractor_id 1
    tender_id 1
    register_date "2013-11-27"
    reason "MyString"
  end
end

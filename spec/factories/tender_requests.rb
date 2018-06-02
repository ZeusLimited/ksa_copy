# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tender_request do
    bidder_id 1
    register_date "2013-11-22"
    inbox_num "MyString"
    inbox_date "2013-11-22"
    request "MyString"
    user_id 1
    outbox_num "MyString"
    outbox_date "2013-11-22"
  end
end

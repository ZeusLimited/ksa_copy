# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :rebid_protocol_present_bidder do
    rebid_protocol_id 1
    bidder_id 1
    delegate "MyString"
  end
end

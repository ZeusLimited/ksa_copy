# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :open_protocol_present_bidder do
    open_protocol_id 1
    bidder_id 1
    delegate "MyString"
  end
end

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :rebid_protocol do
    tender_id 1
    num "MyString"
    confirm_date "2014-07-19"
    confirm_city "MyString"
    rebid_date "2014-07-19"
    location "MyString"
    resolve "MyText"
    clerk { create(:user) }
    commission

    factory :rebid_protocol_with_members do
      after(:create) do |rebid_protocol|
        create(:rebid_protocol_present_member, :boss, rebid_protocol: rebid_protocol)
        create(:rebid_protocol_present_member, :sub_boss, rebid_protocol: rebid_protocol)
        create(:rebid_protocol_present_member, :clerk, rebid_protocol: rebid_protocol, user: rebid_protocol.clerk)
        create(:rebid_protocol_present_member, :member, rebid_protocol: rebid_protocol)
        create(:rebid_protocol_present_member, :member, rebid_protocol: rebid_protocol)
      end
    end
  end
end

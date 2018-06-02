# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :open_protocol do
    num "MyString"
    sign_date "2013-12-20"
    sign_city "MyString"
    open_date "2013-12-20 12:20:20"
    location "MyString"
    resolve "MyText"
    tender
    commission
    clerk { FactoryGirl.create(:user) }
    created_at "2013-12-20"
    updated_at "2013-12-20"

    factory :open_protocol_with_members do
      after(:create) do |open_protocol|
        create(:open_protocol_present_member, :boss, open_protocol: open_protocol)
        create(:open_protocol_present_member, :sub_boss, open_protocol: open_protocol)
        create(:open_protocol_present_member, :clerk, open_protocol: open_protocol, user: open_protocol.clerk)
        create(:open_protocol_present_member, :member, open_protocol: open_protocol)
        create(:open_protocol_present_member, :member, open_protocol: open_protocol)
      end
    end
  end
end

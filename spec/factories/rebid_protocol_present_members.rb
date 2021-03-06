FactoryGirl.define do
  factory :rebid_protocol_present_member do
    rebid_protocol_id 1
    user
    status_id Commissioners::MEMBER

    trait(:boss) { status_id Commissioners::BOSS }
    trait(:sub_boss) { status_id Commissioners::SUB_BOSS }
    trait(:clerk) { status_id Commissioners::CLERK }
    trait(:member) { status_id Commissioners::MEMBER }
  end
end

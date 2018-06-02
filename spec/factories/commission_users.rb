include Constants

FactoryGirl.define do
  factory :commission_user do
    commission
    user
    status Commissioners::MEMBER
    is_veto 1
    user_job Faker::Job.title
    created_at Faker::Time.backward(60)
    updated_at Faker::Time.between(58.days.ago, Time.zone.today)

    trait(:boss) { status Commissioners::BOSS }
    trait(:sub_boss) { status Commissioners::SUB_BOSS }
    trait(:clerk) { status Commissioners::CLERK }
    trait(:member) { status Commissioners::MEMBER }
  end
end

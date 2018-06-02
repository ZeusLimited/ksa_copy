# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :fias_plan_specification do
    # addr_aoid { create(:fias_addr).aoid }
    # houseid ""
    plan_specification
    fias

    after(:build) do |f|
      f.addr_aoid = f.fias.aoid
    end
  end
end

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :fias_specification do
    addr_aoid { create(:fias_addr).aoid }
    specification
    fias
  end
end

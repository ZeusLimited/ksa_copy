# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :local_time_zone do
    name "MyString"
    time_zone "Moscow"
  end
end

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :declension do
    content_type "MyString"
    content_id 1
    name_r "MyString"
    name_d "MyString"
    name_v "MyString"
    name_t "MyString"
    name_p "MyString"
  end
end

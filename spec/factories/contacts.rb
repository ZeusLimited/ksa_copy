# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :contact do
    legal_aoid ""
    legal_houseid ""
    postal_aoid ""
    postal_houseid ""
    web "MyString"
    email "MyString"
    phone "MyString"
    fax "MyString"
    version ""
    department_id 1
  end
end

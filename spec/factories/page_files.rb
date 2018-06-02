# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :page_file do
    page_id 1
    wikifile "MyString"
  end
end

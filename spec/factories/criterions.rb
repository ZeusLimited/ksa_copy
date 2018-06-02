# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :criterion do
    type_criterion "MyString"
    sequence(:list_num)
    name "MyString"

    factory :criterion_draft do
      type_criterion "Draft"
    end

    factory :criterion_evalution do
      type_criterion "Evalution"
    end
  end
end

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :content_offer do
    name "MyText"
    num "MyString"
    position 1
    content_offer_type_id ContentOfferType::HR
  end
end

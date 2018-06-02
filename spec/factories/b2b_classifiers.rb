FactoryGirl.define do
  factory :b2b_classifier do
    classifier_id Faker::Number.number(4)
    parent_classifier_id nil
    name Faker::Lorem.sentence
  end
end

FactoryGirl.define do
  factory :regulation_item do
    num "MyString"
    name "MyText"
    is_actual true

    tender_type_ids { Dictionary.tender_types.pluck(:ref_id) }

    factory :regulation_item_with_tender_types do
      after(:build) do |t|
        t.tender_types { [Dictionary.tender_types] }
      end
    end
  end
end

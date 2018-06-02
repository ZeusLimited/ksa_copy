FactoryGirl.define do
  factory :unfair_contractor do
    num 1
    date_in "2016-04-20"
    contractor
    contract_info "MyText"
    unfair_info "MyText"
    date_out "2016-04-20"
    note "MyText"

    after(:build) do |uc, evaluator|
      uc.lots << create(:lot_with_spec)
    end

  end
end

FactoryGirl.define do
  factory :protocol_file do
    protocol_id 1
    note "MyText"
    tender_file { create(:tender_file, :protocol) }
  end
end

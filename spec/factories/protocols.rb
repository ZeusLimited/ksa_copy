FactoryGirl.define do
  factory :protocol do
    num 1
    date_confirm "2016-01-01"
    location Faker::Address.street_address
    gkpz_year 2016

    # associations
    format_id FormatMeetings::FULL_TIME
    commission

    trait(:level1_kk) do
      commission { create(:commission, :level1_kk) }
    end

    factory :protocol_with_files do
      after(:build) do |pr|
        pr.protocol_files << create(:protocol_file)
      end
    end
  end
end

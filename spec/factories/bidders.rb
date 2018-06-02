FactoryGirl.define do
  factory :bidder do
    tender
    contractor  { create(:contractor, :active) }
    is_presence false

    trait(:with_files) do
      after(:create) do |b|
        create(:bidder_file, bidder_id: b.id, tender_file: create(:tender_file, :bidder))
      end
    end

    trait(:with_covers) do
      after(:create) do |b|
        create(:cover, bidder_id: b.id)
      end
    end
  end
end

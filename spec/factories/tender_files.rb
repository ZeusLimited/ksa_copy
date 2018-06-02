# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tender_file do
    year Date.current.year
    user
    document { File.open("spec/fixtures/temp_file.zip") }

    trait(:plan) do
      area_id Constants::TenderFileArea::PLAN_LOT

      after(:create) do |tf|
        create(:plan_lots_file, tender_file: tf)
      end
    end

    trait(:tender) do
      area_id Constants::TenderFileArea::TENDER

      after(:create) do |tf|
        create(:link_tender_file, tender_file: tf)
      end
    end

    trait(:bidder) do
      area_id Constants::TenderFileArea::BIDDER

      after(:create) do |tf|
        create(:bidder_file, tender_file: tf)
      end
    end

    trait(:contract) do
      area_id Constants::TenderFileArea::CONTRACT

      after(:create) do |tf|
        create(:contract_file, tender_file: tf)
      end
    end

    trait(:protocol) do
      area_id Constants::TenderFileArea::PROTOCOL

      after(:create) do |tf|
        create(:protocol_file, tender_file: tf)
      end
    end

    trait(:contractor) do
      area_id Constants::TenderFileArea::CONTRACTOR

      after(:create) do |tf|
        create(:contractor_file, tender_file: tf)
      end
    end

    trait(:order) do
      area_id Constants::TenderFileArea::ORDER

      after(:create) do |tf|
        create(:order_file, tender_file: tf)
      end
    end
  end
end

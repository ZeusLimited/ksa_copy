# Read about factories at https://github.com/thoughtbot/factory_girl
include GuidGenerate
FactoryGirl.define do
  factory :fias do
    aoid_hex { SecureRandom.uuid }
    houseid_hex { SecureRandom.uuid }
    name 'Тест'
    postalcode '680000'
    regioncode '27'
    okato '12345678910'
    oktmo '12345678910'
  end
end

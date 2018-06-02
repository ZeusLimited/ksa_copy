FactoryGirl.define do
  factory :effeciency_indicator do
    gkpz_year Time.current.year
    work_name "single_source"
    name "name"
    value 50.0
  end
end

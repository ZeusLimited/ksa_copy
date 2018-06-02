include Constants

FactoryGirl.define do
  factory :unit do
    code "Mystring"
    name "Mystring"
    symbol_name "Mystring"

    trait(:default_unit) do
      code Units::DEFAULT_UNIT
      name "Условная единица"
      symbol_name "усл. ед"
    end
  end
end

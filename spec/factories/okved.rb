FactoryGirl.define do
  factory :okved do
    code "Mystring"
    name "Mystring"
    ref_type 'OKVED'

    factory :okved_new do
      ref_type 'OKVED2'
    end
  end
end

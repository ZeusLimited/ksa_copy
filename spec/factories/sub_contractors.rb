FactoryGirl.define do
  factory :sub_contractor do
    contract
    contractor

    name "MyString"
    confirm_date "2015-10-28"
    num "MyString"
    begin_date "2015-11-01"
    end_date "2015-11-25"
  end
end

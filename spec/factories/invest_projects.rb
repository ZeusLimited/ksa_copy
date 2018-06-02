# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :invest_project do
    num "string"
    name "string"
    gkpz_year 2014
    department_id 1
    project_type_id 1
    object_name "string"
    date_install "2014-01-20"
    amount_financing 123.45
    # amount_financing_money 123.45
    power_elec_gen 1.0
    power_elec_net 1.0
    power_substation 1.0
    power_thermal_gen 1.0
    power_thermal_net 1.0

    invest_project_name

    factory :invest_project_with_spec do
      plan_specifications { [FactoryGirl.create(:plan_specification, plan_lot: FactoryGirl.create(:plan_lot))] }
    end

  end
end

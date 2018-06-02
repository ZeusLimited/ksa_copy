require 'csv'

namespace :order1352 do
  desc 'Load csv file'
  task load_csv: :environment do
    arr_of_arrs = CSV.read('tmp/1352/yagres2.csv', col_sep: ';', encoding: 'windows-1251')

    orders = Dictionary.order1352

    lines = arr_of_arrs.map do |a|
      {
        guid: a[0],
        str: a[1],
        code: orders.find { |o| o.fullname == a[1] }.ref_id
      }
    end

    puts lines

    lines.each do |l|
      PlanSpecification.guid_eq(:guid, l[:guid]).update_all(order1352_id: l[:code])
    end
  end
end

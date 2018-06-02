
ValidTenderDate.delete_all
TenderDatesForType.delete_all

tdft = YAML.load(File.read(File.join(Rails.root, 'db', 'seeds', 'yaml', 'tender_dates_for_types.yml')))
ap tdft
tdft.each do |v|
  p = ValidTenderDate.create(count_date: v['count_date'])
  v['tender_type_id'].each { |tt| TenderDatesForType.create(tender_date_id: p.id, tender_type_id: tt) }
end

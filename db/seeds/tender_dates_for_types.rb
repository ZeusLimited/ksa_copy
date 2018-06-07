
TenderDatesForType.delete_all

tdft = YAML.load(File.read(File.join(Rails.root, 'db', 'seeds', 'yaml', 'tender_dates_for_types.yml')))
ap tdft
tdft.each do |v|
  v['tender_type_id'].each { |tt| TenderDatesForType.create(days: v['count_date'], tender_type_id: tt) }
end

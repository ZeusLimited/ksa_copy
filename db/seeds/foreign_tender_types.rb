vals = YAML.load(File.read(File.join(Rails.root, 'db', 'seeds', 'yaml', 'foreign_tender_types.yml')))

ForeignTenderType.delete_all

vals.each do |v|
  puts v
  ForeignTenderType.create(v)
end

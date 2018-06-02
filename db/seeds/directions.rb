vals = YAML.load(File.read(File.join(Rails.root, 'db', 'seeds', 'yaml', 'directions.yml')))

Direction.delete_all

vals.each do |v|
  puts v
  Direction.create(v)
end

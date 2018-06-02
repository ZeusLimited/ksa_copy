vals = YAML.load(File.read(File.join(Rails.root, 'db', 'seeds', 'yaml', 'roles.yml')))

Role.delete_all

vals.each do |v|
  puts v
  Role.create(v)
end

vals = YAML.load(File.read(File.join(Rails.root, 'db', 'seeds', 'yaml', 'arm_departments.yml')))

ArmDepartment.delete_all

vals.each do |v|
  puts v
  ArmDepartment.create(v)
end

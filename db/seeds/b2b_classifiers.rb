vals = YAML.load(File.read(File.join(Rails.root, 'db', 'seeds', 'yaml', 'b2b_classifiers.yml')))

B2bClassifier.delete_all

vals.each do |v|
  puts v
  B2bClassifier.create(v)
end

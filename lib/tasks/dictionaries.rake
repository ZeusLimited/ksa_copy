namespace :db do
  namespace :seed do
    namespace :dictionaries do
      task_names = []
      Dir[File.join(Rails.root, 'db', 'seeds', 'yaml', 'dictionaries', '*.yml')].each do |filename|
        task_name = File.basename(filename, '.yml').intern
        task_names << task_name
        desc "Load dictionaries from #{filename}"
        task task_name => :environment do
          vals = YAML.load(File.read(filename))
          dics = Dictionary.send(task_name)
          dics.delete_all

          vals.each do |v|
            puts v
            v.merge!(is_actual: true)
            v.merge!(fullname: v['name']) unless v.has_key?('fullname')
            dics.create(v)
          end
        end
      end

      desc "Load all dictionaries"
      task all: task_names
    end
  end
end

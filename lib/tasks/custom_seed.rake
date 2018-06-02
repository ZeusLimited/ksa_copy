namespace :db do
  namespace :seed do
    task_names = []
    Dir[File.join(Rails.root, 'db', 'seeds', '*.rb')].each do |filename|
      task_name = File.basename(filename, '.rb').intern
      task_names << task_name
      desc "db/seeds/#{task_name.to_s}.rb"
      task task_name => :environment do
        load(filename) if File.exist?(filename)
      end
    end

    desc "Run all rake files in db/seeds"
    task all: task_names
  end
end

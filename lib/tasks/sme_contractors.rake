def create_contractor(old_contractor)
  contractor = old_contractor.deep_clone except: [:is_sme, :sme_type_id]
  contractor.prev_id = old_contractor.id
  contractor.save! validate: false
  old_contractor.next_id = contractor.id
  old_contractor.status = 2
  old_contractor.save validate: false
rescue ActiveRecord::RecordInvalid => invalid
  puts "Something goes wrong with #{old_contractor.id} - #{old_contractor.name}"
  puts invalid.record.errors.full_messages
end

namespace :contractors_sme do
  desc "Изменение всех МСП организаций"
  task :create_new_version => :environment do
    time_begin = Time.now
    puts 'Start create sme contractors new versions...'
    contractors_sme = Contractor.where.not(status: [2, 3]).where("is_sme is not null or sme_type_id is not null")
    Contractor.transaction do
      contractors_sme.each do |contractor|
        create_contractor contractor
      end
    end
    time_end = Time.now
    puts "Updated #{contractors_sme.size} records in #{(time_end - time_begin).to_i} seconds"
  end
end

require 'sys/filesystem'

namespace :upload do
  desc "Удаление файлов, которые есть на диске и нет в базе"
  task delete_through_folder: :environment do
    years = 2008..Time.now.year

    years.each do |year|
      upload_dir = Rails.root.join('public', 'uploads', year.to_s)

      puts "Search files in folder: #{upload_dir}"
      files = Dir[File.join(upload_dir, "**", "*.*")]

      puts "Found #{files.size} files"

      # files.each do |f|
      #   TenderFile.where(area_id: ).where(year: year).where(document: 1).exists?(5)
      # end
    end
  end

  def mb_available_upload
    mp = Sys::Filesystem.mount_point(Rails.root.join('public', 'uploads'))
    stat = Sys::Filesystem.stat(mp)
    stat.block_size * stat.blocks_available / 1024 / 1024
  end

  desc "Удаление файлов, у которых нет связи в базе"
  task delete_through_db: :environment do
    mb_available_before = mb_available_upload

    tender_files =
      TenderFile
      .joins('left join plan_lots_files plf on plf.tender_file_id = tender_files.id and tender_files.area_id = 1')
      .joins('left join link_tender_files ltf on ltf.tender_file_id = tender_files.id and tender_files.area_id = 2')
      .joins('left join bidder_files bf on bf.tender_file_id = tender_files.id and tender_files.area_id = 3')
      .joins('left join contract_files cf on cf.tender_file_id = tender_files.id and tender_files.area_id = 4')
      .joins('left join protocol_files pf on pf.tender_file_id = tender_files.id and tender_files.area_id = 5')
      .where('plf.id is null')
      .where('ltf.id is null')
      .where('bf.id is null')
      .where('cf.id is null')
      .where('pf.id is null')
      .where('tender_files.created_at < ?', 10.day.ago)

    puts "Found unused files in db: #{tender_files.count}"
    i = 0
    tender_files.find_in_batches do |group|
      group.each do |tf|
        i += 1
        print i
        tf.destroy
        print 13.chr
      end
    end

    puts ""

    mb_available_after = mb_available_upload

    puts "Free up space: #{mb_available_before - mb_available_after} MB"
  end
end

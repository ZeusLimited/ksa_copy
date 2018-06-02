module Import
  extend ActiveSupport::Concern
  include Constants

  class_methods do

    def import(file, current_user)
      spreadsheet = open_spreadsheet(file)

      header = spreadsheet.row(1)

      ImportLot.where(user_id: current_user.id).delete_all
      (3..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]
        lot = current_user.import_lots.build(num: i - 2)
        lot.attributes = row.to_hash.slice(*ImportLot.columns.map(&:name))
        lot.save!(validate: false)
      end
    end

    def open_spreadsheet(file)
      case File.extname(file.original_filename)
      # when ".csv" then Csv.new(file.path, nil, :ignore)
      # when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
      when ".xlsx" then Roo::Excelx.new(file.path)
      else fail CanCan::AccessDenied, "Неизвестный тип файла: #{file.original_filename}"
      end
    end
  end
end
def load_okei
  ActiveRecord::Base.transaction do
    puts "load okei"
    UnitTitle.delete_all
    UnitSubtitle.delete_all
    Unit.delete_all

    files = Dir[Rails.root.join('db','csv', 'units', '**', '*.csv')]

    files.each do |file|
      lines = File.readlines(file)

      title = File.basename(File.dirname(file)).to_s
      subtitle = File.basename(file, '.csv').to_s

      unit_title = UnitTitle.find_or_create_by(name: title)
      unit_subtitle = UnitSubtitle.find_or_create_by(name: subtitle)

      lines.each do |line|
        csv_arr = line.parse_csv;
        Unit.create(
          code: csv_arr[0].rjust(3,'0'),
          name: csv_arr[1],
          symbol_n: csv_arr[2],
          symbol_i: csv_arr[3],
          letter_n: csv_arr[4],
          letter_i: csv_arr[5],
          unit_title_id: unit_title.id,
          unit_subtitle_id: unit_subtitle.id,
          symbol_name: csv_arr[2] ? csv_arr[2] : csv_arr[3] == '-' ? csv_arr[5] : csv_arr[3])
      end
    end
  end
end


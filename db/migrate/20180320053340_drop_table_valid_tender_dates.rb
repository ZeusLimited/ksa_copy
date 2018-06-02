class DropTableValidTenderDates < ActiveRecord::Migration[5.1]
  include MigrationHelper
  def up
    add_column_with_comment :tender_dates_for_types,
                            :days,
                            :integer,
                            comment: 'Кол-во дней'

    execute <<-SQL
      update tender_dates_for_types set days = (select v.count_date from
        valid_tender_dates v where v.id = tender_dates_for_types.tender_date_id)
    SQL

    drop_table :valid_tender_dates

    remove_column :tender_dates_for_types, :tender_date_id
  end

  def down
    create_table :valid_tender_dates, comment: 'Кол-во дней при валидации даты вскрытия конвертов' do |t|
      t.integer :count_date, comment: 'Кол-во дней', null: false
    end

    execute <<-SQL
      insert into valid_tender_dates (count_date) select distinct days from tender_dates_for_types
    SQL

    add_column_with_comment :tender_dates_for_types,
                            :tender_date_id,
                            :integer,
                            comment: 'ИД кол-во дней'

    execute <<-SQL
      update tender_dates_for_types set tender_date_id = (select v.id from
        valid_tender_dates v where v.count_date = tender_dates_for_types.days)
    SQL

    remove_column :tender_dates_for_types, :days
  end
end

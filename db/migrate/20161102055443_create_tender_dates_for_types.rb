class CreateTenderDatesForTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :tender_dates_for_types, comment: 'Связь кол-во дней при валидации даты вскрытия конвертов с типом закупки' do |t|
      t.integer :tender_date_id, comment: 'ИД кол-во дней', null: false
      t.integer :tender_type_id, comment: 'ИД типа закупки', null: false
    end
  end
end

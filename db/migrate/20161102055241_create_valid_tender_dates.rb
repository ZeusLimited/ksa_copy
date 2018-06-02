class CreateValidTenderDates < ActiveRecord::Migration[4.2]
  def change
    create_table :valid_tender_dates, comment: 'Кол-во дней при валидации даты вскрытия конвертов' do |t|
      t.integer :count_date, comment: 'Кол-во дней', null: false
    end
  end
end

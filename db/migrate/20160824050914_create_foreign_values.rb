class CreateForeignValues < ActiveRecord::Migration[4.2]
  def change
    create_table :foreign_values, id: false, comment: 'Таблица для сопоставления значений справочников с внешними система' do |t|
      t.string "foreign_id", null: false, comment: 'Внешний ключ'
      t.string "foreign_system", null: false, comment: 'Название системы'
      t.string "inner_id", null: false, comment: 'Внутренний ключ'
      t.string "dictionary_name", null: false, comment: 'Название справочника'
    end
  end
end

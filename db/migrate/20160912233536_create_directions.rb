class CreateDirections < ActiveRecord::Migration[4.2]
  def change
    create_table :directions, comment: 'Направления деятельности (разделы ГКПЗ)' do |t|
      t.string :name, comment: 'Наименование', null: false
      t.string :fullname, comment: 'Полное наименование', null: false
      t.integer :type_id, comment: 'Тип направления деятельности', null: false
      t.integer :position, comment: 'Порядок', null: false
      t.string :yaml_key, comment: 'Ключ для yaml файлов отчетов'
      t.boolean :is_longterm, comment: 'Долгосрочный горизонт планирования?', null: false, default: false

      t.timestamps null: false
    end
  end
end

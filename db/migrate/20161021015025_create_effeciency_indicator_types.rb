class CreateEffeciencyIndicatorTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :effeciency_indicator_types, comment: 'Типы контрольных показателей' do |t|
      t.string :work_name, comment: 'Рабочее название КПЭ', null: false
      t.text :name, comment: 'Полное наименование КПЭ', null: false
      t.float :weight, comment: 'Вес КПЭ', null: false

      t.timestamps null: false
    end
  end
end

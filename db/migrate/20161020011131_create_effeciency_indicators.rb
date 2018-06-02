class CreateEffeciencyIndicators < ActiveRecord::Migration[4.2]
  def change
    create_table :effeciency_indicators, comment: 'Контрольные показатели для расчета КПЭ' do |t|
      t.integer :gkpz_year, comment: 'Год ГКПЗ', null: false
      t.string :work_name, comment: 'Рабочее наименование', null: false
      t.text :name, comment: 'Наименование показателя', null: false
      t.float :value, comment: 'Значение показателя', null: false
    end
  end
end

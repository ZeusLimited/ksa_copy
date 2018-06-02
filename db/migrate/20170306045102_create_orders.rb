class CreateOrders < ActiveRecord::Migration[4.2]
  def change
    create_table :orders do |t|
      t.string :num, comment: 'Номер поручения'
      t.date :receiving_date, comment: 'Дата получения поручения'
      t.date :agreement_date, comment: 'Дата согласования поручения'
      t.integer :received_from_user_id, comment: 'Приславший поручение'
      t.integer :agreed_by_user_id, comment: 'Согласовавший поручение'

      t.timestamps null: false
    end
  end
end

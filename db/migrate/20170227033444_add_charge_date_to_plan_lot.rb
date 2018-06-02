class AddChargeDateToPlanLot < ActiveRecord::Migration[4.2]
  include MigrationHelper
  def change
    add_column :plan_lots, :charge_date, :date
    column_comment :plan_lots, :charge_date, 'Дата направления поручения'
  end
end

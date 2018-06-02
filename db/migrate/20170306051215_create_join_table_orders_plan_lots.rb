class CreateJoinTableOrdersPlanLots < ActiveRecord::Migration[4.2]
  include MigrationHelper
  def change
    create_join_table :orders, :plan_lots do |t|
      t.index [:order_id, :plan_lot_id]
    end
  end
end

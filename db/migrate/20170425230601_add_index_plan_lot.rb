class AddIndexPlanLot < ActiveRecord::Migration[4.2]
  def change
    add_index :lots, :plan_lot_id, name: 'i_lots_plan_lot_id'
    add_index :lots, :plan_lot_guid, name: 'i_lots_plan_lot_guid'
  end
end

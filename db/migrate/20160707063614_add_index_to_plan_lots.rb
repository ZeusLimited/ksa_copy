class AddIndexToPlanLots < ActiveRecord::Migration[4.2]
  def change
    add_index :plan_lots, :protocol_id, name: 'i_plan_lots_protocol'
  end
end

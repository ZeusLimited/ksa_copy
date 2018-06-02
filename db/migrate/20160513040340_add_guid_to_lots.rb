class AddGuidToLots < ActiveRecord::Migration[4.2]
  include MigrationHelper
  def change
    add_guid_column :lots, :plan_lot_guid
    column_comment :lots, :plan_lot_guid, 'Глобальный идентификатор контрагента'
    execute <<-SQL
      update lots set plan_lot_guid = (select guid from plan_lots where id = lots.plan_lot_id)
    SQL
  end
end

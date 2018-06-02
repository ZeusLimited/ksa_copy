class AddToRegulationItem < ActiveRecord::Migration[4.2]
  include MigrationHelper
  def up
    create_join_table :regulation_items, :departments do |t|
      t.index :regulation_item_id
      t.index :department_id
    end
  end

  def down
    drop_join_table :regulation_items, :departments
  end
end

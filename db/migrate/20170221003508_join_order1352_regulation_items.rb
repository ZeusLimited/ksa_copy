class JoinOrder1352RegulationItems < ActiveRecord::Migration[4.2]
  include MigrationHelper
  def up
    create_join_table :regulation_items, :dictionaries do |t|
      t.index :regulation_item_id
      t.index :dictionary_id
    end
  end

  def down
    drop_join_table :regulation_items, :dictionaries
  end
end

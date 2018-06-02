class AddParentIdToContractors < ActiveRecord::Migration[4.2]
  include MigrationHelper
  def change
    add_column :contractors, :parent_id, :string
    column_comment :contractors, :parent_id, 'Ссылка на родителя'
    add_index :contractors, :parent_id
  end
end

class AddAncestryToOkved < ActiveRecord::Migration[4.2]
  def change
    add_column :okved, :ancestry, :string
    add_index :okved, :ancestry
  end
end

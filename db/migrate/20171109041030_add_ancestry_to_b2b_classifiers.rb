class AddAncestryToB2bClassifiers < ActiveRecord::Migration[5.1]
  def change
    add_column :b2b_classifiers, :ancestry, :string
    add_index :b2b_classifiers, :ancestry
  end
end

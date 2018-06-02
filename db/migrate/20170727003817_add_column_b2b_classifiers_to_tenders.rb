class AddColumnB2bClassifiersToTenders < ActiveRecord::Migration[5.0]
  include MigrationHelper
  def change
    add_column :tenders, :b2b_classifiers, :integer, array: true, default: []
    column_comment :tenders, :b2b_classifiers, 'Классификаторы b2b-center'
  end
end

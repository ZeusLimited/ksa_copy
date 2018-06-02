class AddParentClassifierIdToB2bClassifier < ActiveRecord::Migration[5.1]
  include MigrationHelper
  def change
    add_column_with_comment :b2b_classifiers, :parent_classifier_id, :integer, comment: 'Id родительского элемента'
  end
end

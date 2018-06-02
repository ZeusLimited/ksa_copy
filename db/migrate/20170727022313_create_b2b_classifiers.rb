class CreateB2bClassifiers < ActiveRecord::Migration[5.0]
  include MigrationHelper
  def change
    create_table :b2b_classifiers do |t|
      t.integer :classifier_id
      t.text :name

      t.timestamps
    end
    add_index :b2b_classifiers, :classifier_id

    table_comment :b2b_classifiers, 'Классификаторы b2b-center'
    column_comment :b2b_classifiers, :classifier_id, 'Id классификатора на площадке b2b'
    column_comment :b2b_classifiers, :name, 'Наименование классификатора'
  end
end

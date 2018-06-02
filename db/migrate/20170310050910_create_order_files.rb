class CreateOrderFiles < ActiveRecord::Migration[4.2]
  def change
    create_table :order_files do |t|
      t.string :note
      t.integer :order_id, null: false, index: true
      t.integer :tender_file_id, null: false, index: true

      t.timestamps null: false
    end
  end
end

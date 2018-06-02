class CreateMainContacts < ActiveRecord::Migration[4.2]
  def change
    create_table :main_contacts do |t|
      t.string :role
      t.integer :position
      t.references :user, index: true

      t.timestamps null: false
    end
  end
end

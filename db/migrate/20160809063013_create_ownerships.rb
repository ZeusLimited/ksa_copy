class CreateOwnerships < ActiveRecord::Migration[4.2]
  def change
    create_table :ownerships do |t|
      t.string :shortname
      t.string :fullname
      t.timestamps null: false
    end
  end
end

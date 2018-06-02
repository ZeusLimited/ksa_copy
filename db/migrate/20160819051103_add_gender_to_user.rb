class AddGenderToUser < ActiveRecord::Migration[4.2]
  include MigrationHelper
  def change
    add_column :users, :gender, :integer
    column_comment :users, :gender, 'Пол (женский, мужской)'
  end
end

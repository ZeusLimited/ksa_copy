class AddShortnameToDepartments < ActiveRecord::Migration[4.2]
  include MigrationHelper
  def change
    add_column :departments, :shortname, :string, limit: 25
    column_comment :departments, :shortname, 'Сокращенное наименование'
  end
end

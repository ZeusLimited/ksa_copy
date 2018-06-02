class AddIsConsumerToDepartments < ActiveRecord::Migration[4.2]
  include MigrationHelper
  def change
    add_column :departments, :is_consumer, :boolean
    column_comment :departments, :is_consumer, 'Является потребителем?'
  end
end

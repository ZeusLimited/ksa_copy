class AddOrderIdToLots < ActiveRecord::Migration[4.2]
  include MigrationHelper
  def change
    add_column :lots, :order_id, :integer, index: true
    column_comment :lots, :order_id, 'Id поручения'
  end
end

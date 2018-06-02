class AddForCustomersToCommissions < ActiveRecord::Migration[5.0]
  include MigrationHelper
  def change
    add_column_with_comment :commissions,
                            :for_customers,
                            :boolean,
                            default: false,
                            null: false,
                            comment: 'Может проводить закупки для сторонних заказчиков'
  end
end

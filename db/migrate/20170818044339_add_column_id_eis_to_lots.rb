class AddColumnIdEisToLots < ActiveRecord::Migration[5.0]
  include MigrationHelper
  def change
    add_column_with_comment :lots,
                            :id_eis,
                            :string,                            
                            comment: 'Уникальный номер на ЕИС'
  end
end

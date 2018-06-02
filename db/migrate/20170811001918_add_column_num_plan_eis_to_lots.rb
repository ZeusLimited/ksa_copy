class AddColumnNumPlanEisToLots < ActiveRecord::Migration[5.0]
  include MigrationHelper
  def change    
    add_column_with_comment :lots,
                            :num_plan_eis,
                            :string,
                            limit: 20,
                            comment: 'Номер позиции плана на ЕИС'
  end
end

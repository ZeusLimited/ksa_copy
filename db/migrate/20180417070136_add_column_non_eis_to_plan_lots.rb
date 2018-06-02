class AddColumnNonEisToPlanLots < ActiveRecord::Migration[5.1]
  include MigrationHelper
  def change
    add_column_with_comment :plan_lots,
                            :non_eis,
                            :boolean,
                            default: false,
                            null: false,
                            comment: 'Не публикуется в план закупок ЕИС'
  end
end

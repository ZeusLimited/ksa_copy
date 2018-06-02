class AddProductionUnitToPlanSpecifications < ActiveRecord::Migration[4.2]
  include MigrationHelper
  def change
    add_column :plan_specifications, :production_unit_id, :integer
    column_comment :plan_specifications, :production_unit_id, 'Производственное подразделение'
  end
end

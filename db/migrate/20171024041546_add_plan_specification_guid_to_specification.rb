class AddPlanSpecificationGuidToSpecification < ActiveRecord::Migration[5.1]
  include MigrationHelper
  def change
    add_guid_column :specifications, :plan_specification_guid
    column_comment :specifications, :plan_specification_guid, 'Глобальный идентификатор плановой спецификации'
    execute <<-SQL
      update specifications set plan_specification_guid = (select guid from plan_specifications where id = specifications.plan_specification_id)
    SQL
  end
end

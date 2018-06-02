class AddColumnOwnershipIdToDepartments < ActiveRecord::Migration[4.2]
  include MigrationHelper
  def change
    add_column :departments, :ownership_id, :integer
    column_comment :departments, :ownership_id, 'Идентификатор вида собственности'

    execute <<-SQL
      update departments
        set ownership_id =
          (select o.id from ownerships o
            where LOWER(RTRIM(LTRIM(ownership))) = LOWER(o.shortname)
          )
    SQL

  end
end

class AddOwnershipToContractors < ActiveRecord::Migration[4.2]
  include MigrationHelper
  def change
    add_column :contractors, :ownership_id, :integer
    column_comment :contractors, :ownership_id, 'Идентификатор вида собственности'

    add_index :ownerships, [:id, :shortname], unique: true

    execute <<-SQL
      update contractors
        set ownership_id =
          (select o.id from ownerships o
            where LOWER(RTRIM(LTRIM(ownership))) = LOWER(o.shortname)
          )
    SQL

  end
end

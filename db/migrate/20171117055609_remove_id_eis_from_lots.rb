class RemoveIdEisFromLots < ActiveRecord::Migration[5.1]
  def change
    execute <<-SQL
      update lots set num_plan_eis = id_eis where length(id_eis) > 0
    SQL
    remove_column :lots, :id_eis, :string
  end
end

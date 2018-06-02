class ChangeOosNumInTenders < ActiveRecord::Migration[4.2]
  include MigrationHelper
  def up
    if ActiveRecord::Base.postgres_adapter?
      change_column :tenders, :oos_num, :bigint
      change_column :tenders, :oos_id, :bigint
    end
  end

  def down
    if ActiveRecord::Base.postgres_adapter?
      change_column :tenders, :oos_num, :integer
      change_column :tenders, :oos_id, :integer
    end
  end
end

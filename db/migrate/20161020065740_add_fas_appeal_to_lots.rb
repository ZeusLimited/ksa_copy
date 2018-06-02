class AddFasAppealToLots < ActiveRecord::Migration[4.2]
  include MigrationHelper
  def change
    add_column :lots, :fas_appeal, :integer, default: 0, limit: 1
    column_comment :lots, :fas_appeal, 'По закупке подана жалоба в ФАС'
  end
end

class TemporaryChangeStatusChangeFunction < ActiveRecord::Migration[5.0]
  def up
    sql = IO.read('./db/sql/postgresql/change_status.sql')
    ActiveRecord::Base.connection.execute(sql)
  end

  def down; end
end

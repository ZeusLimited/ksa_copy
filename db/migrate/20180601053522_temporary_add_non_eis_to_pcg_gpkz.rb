class TemporaryAddNonEisToPcgGpkz < ActiveRecord::Migration[5.1]
  def up
    sql = IO.read('./db/sql/postgresql/change_status.sql')
    ActiveRecord::Base.connection.execute(sql)
    sql = IO.read('./db/sql/postgresql/bind_lots_to_protocol.sql')
    ActiveRecord::Base.connection.execute(sql)
  end

  def down; end
end

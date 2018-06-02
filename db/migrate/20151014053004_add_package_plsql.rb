class AddPackagePlsql < ActiveRecord::Migration[4.2]
  def up
    if ActiveRecord::Base.oracle_adapter?
      sql = IO.read('./db/sql/oracle/gkpz_package.sql')
      ActiveRecord::Base.connection.execute(sql)
      sql = IO.read('./db/sql/oracle/gkpz_package_body.sql')
      ActiveRecord::Base.connection.execute(sql)
    elsif ActiveRecord::Base.postgres_adapter?
      sql = IO.read('./db/sql/postgresql/pcg_gkpz_schema.sql')
      ActiveRecord::Base.connection.execute(sql)
      sql = IO.read('./db/sql/postgresql/change_status.sql')
      ActiveRecord::Base.connection.execute(sql)
      sql = IO.read('./db/sql/postgresql/bind_lots_to_protocol.sql')
      ActiveRecord::Base.connection.execute(sql)
    end
  end

  def down
    if ActiveRecord::Base.oracle_adapter?
      ActiveRecord::Base.connection.execute("DROP package pcg_gkpz")
    elsif ActiveRecord::Base.postgres_adapter?
      ActiveRecord::Base.connection.execute("DROP SCHEMA pcg_gkpz cascade")
    end
  end
end

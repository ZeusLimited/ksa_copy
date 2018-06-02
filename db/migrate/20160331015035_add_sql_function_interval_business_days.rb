class AddSqlFunctionIntervalBusinessDays < ActiveRecord::Migration[4.2]
  def up
    if ActiveRecord::Base.oracle_adapter?
      sql = IO.read('./db/sql/oracle/interval_business_date.sql')
      ActiveRecord::Base.connection.execute(sql)
    elsif ActiveRecord::Base.postgres_adapter?
      sql = IO.read('./db/sql/postgresql/interval_business_date.sql')
      ActiveRecord::Base.connection.execute(sql)
    end
  end

  def down
    ActiveRecord::Base.connection.execute("DROP FUNCTION interval_business_date")
  end
end

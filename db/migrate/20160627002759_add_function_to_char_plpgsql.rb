class AddFunctionToCharPlpgsql < ActiveRecord::Migration[4.2]
  def up
    if ActiveRecord::Base.postgres_adapter?
      sql = IO.read('./db/sql/postgresql/to_char_text.sql')
      ActiveRecord::Base.connection.execute(sql)
    end
  end

  def down
    if ActiveRecord::Base.postgres_adapter?
      ActiveRecord::Base.connection.execute("DROP FUNCTION public.to_char(text);")
    end
  end
end

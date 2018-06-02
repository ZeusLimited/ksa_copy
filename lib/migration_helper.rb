module MigrationHelper
  def oracle_adapter?
    false
  end

  def postgres_adapter?
    ActiveRecord::Base.connection.class == ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
  end

  def add_column_with_comment(table_name, column_name, type, options = {})
    comment = options.delete(:comment)
    add_column table_name, column_name, type, options
    column_comment table_name, column_name, comment
  end

  def add_guid_column(table, column, options = {})
    return add_column table, column, :raw, options.merge(limit: 16) if oracle_adapter?
    add_column table, column, :uuid
  end

  def guid_column(table, column, options = {})
    return table.raw(column, options.merge(limit: 16)) if oracle_adapter?
    table.uuid column, options
  end

  def table_comment(table, comment)
    return add_table_comment table, comment if oracle_adapter?
    set_table_comment table, comment
  end

  def column_comment(table, column, comment)
    return add_comment table, column, comment if oracle_adapter?
    set_column_comment table, column, comment
  end

  def next_sequence_id(table)
    return "#{table}_seq.nextval" if oracle_adapter?
    "nextval('#{table}_id_seq')"
  end
end

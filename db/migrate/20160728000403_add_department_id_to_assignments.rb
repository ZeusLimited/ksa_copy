class AddDepartmentIdToAssignments < ActiveRecord::Migration[4.2]
  include MigrationHelper
  def up
    execute <<-SQL
      create table assignments_temp as select * from assignments
    SQL

    drop_table :assignments

    create_table :assignments do |t|
      t.integer :user_id, null: false
      t.integer :role_id, null: false
      t.integer :department_id
    end

    if ActiveRecord::Base.postgres_adapter?
      execute <<-SQL
        insert into assignments (id, user_id, role_id, department_id)
        select nextval('assignments_id_seq'), a.user_id, a.role_id, u.root_dept_id
        from assignments_temp a
          inner join users u on a.user_id = u.id
      SQL
    else
      execute <<-SQL
        insert into assignments (id, user_id, role_id, department_id)
        select assignments_seq.nextval, a.user_id, a.role_id, u.root_dept_id
        from assignments_temp a
          inner join users u on a.user_id = u.id
      SQL
    end

    drop_table :assignments_temp
  end

  def down
    remove_column :assignments, :id
    remove_column :assignments, :department_id
  end
end

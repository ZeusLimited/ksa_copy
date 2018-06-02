class AddColumnDepartments < ActiveRecord::Migration[4.2]
  def change
    add_column :departments, :full_ownership, :string
  end
end

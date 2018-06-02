class AddProductionUnitsJoinTable < ActiveRecord::Migration[4.2]
  def change
    create_join_table :plan_specifications, :departments, table_name: 'plan_spec_production_units' do |t|
      t.index :plan_specification_id
      t.integer :department_id
    end

    reversible do |r|
      r.up do
        execute <<-SQL
          INSERT INTO plan_spec_production_units
          SELECT
            id, production_unit_id
          FROM plan_specifications
          WHERE production_unit_id IS NOT NULL
        SQL
      end
      r.down do
        execute <<-SQL
          UPDATE plan_specifications
          SET production_unit_id = (SELECT department_id FROM plan_spec_production_units WHERE plan_specification_id = plan_specifications.id AND ROWNUM = 1)
        SQL
      end
    end

    remove_column :plan_specifications, :production_unit_id, :integer
  end
end

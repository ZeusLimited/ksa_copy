class AddIndexToPlanSpecAmounts < ActiveRecord::Migration[4.2]
  def change
    add_index :plan_spec_amounts, :plan_specification_id, name: 'i_plan_spec_amounts_spec_id'
  end
end

# frozen_string_literal: true

class AddFiasIdsToPlanSpecifications < ActiveRecord::Migration[5.1]
  def change
    add_index :fias_plan_specifications, [:plan_specification_id]
    add_index :fias_specifications, [:specification_id]
  end
end

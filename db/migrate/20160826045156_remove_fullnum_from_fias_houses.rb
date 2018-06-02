class RemoveFullnumFromFiasHouses < ActiveRecord::Migration[4.2]
  def change
    remove_column :fias_houses, :fullnum, :string
  end
end

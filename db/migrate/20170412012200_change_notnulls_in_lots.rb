class ChangeNotnullsInLots < ActiveRecord::Migration[4.2]
  def change
    change_column_null :lots, :not_lead_contract, true
    change_column_null :lots, :no_contract_next_bidder, true
  end
end

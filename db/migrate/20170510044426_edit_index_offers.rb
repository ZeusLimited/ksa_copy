class EditIndexOffers < ActiveRecord::Migration[4.2]
  def up
    remove_index :offers, name: :i_offers_bidder_lot_num_vers
    add_index :offers, [:bidder_id, :lot_id, :num, :version],
      name: :i_offers_bidder_lot_num_vers,
      unique: false,
      using: :btree
  end

  def down
    remove_index :offers, name: :i_offers_bidder_lot_num_vers
    add_index :offers, [:bidder_id, :lot_id, :num, :version],
      name: :i_offers_bidder_lot_num_vers,
      unique: true,
      using: :btree
  end
end

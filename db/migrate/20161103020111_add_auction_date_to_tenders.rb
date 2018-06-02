class AddAuctionDateToTenders < ActiveRecord::Migration[4.2]
  include MigrationHelper
  def change
    add_column :tenders, :auction_date, :datetime
    column_comment :tenders, :auction_date, 'Дата и время проведение аукциона на b2b'
  end
end

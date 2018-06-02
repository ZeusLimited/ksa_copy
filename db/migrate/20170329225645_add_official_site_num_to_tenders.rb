class AddOfficialSiteNumToTenders < ActiveRecord::Migration[4.2]
  include MigrationHelper
  def change
    add_column_with_comment :tenders, :official_site_num, :string, limit: 25, comment: 'Номер закупки на официальном сайте общества'
  end
end

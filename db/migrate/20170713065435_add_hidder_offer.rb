class AddHidderOffer < ActiveRecord::Migration[5.0]
  include MigrationHelper
  def change
    add_column :tenders, :hidden_offer, :boolean, dafault: false
    column_comment :tenders, :hidden_offer, 'Использовать ли закрытую подачу предложений'
  end
end

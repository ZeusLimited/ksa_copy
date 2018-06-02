class AddLimitOfferSum < ActiveRecord::Migration[5.1]
  include MigrationHelper
  def change
    add_column_with_comment :tenders, :price_begin_limited,
      :boolean, dafault: false,
      comment: 'Ограничивать предложения участников указанной в извещении стоимостью'
  end
end

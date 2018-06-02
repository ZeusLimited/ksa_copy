class AddAmountNextYearToImportLots < ActiveRecord::Migration[4.2]
  include MigrationHelper
  def change
    add_column :import_lots, :amount_mastery_next_year, :string
    add_column :import_lots, :amount_mastery_nds_next_year, :string
    column_comment :import_lots, :amount_mastery_next_year, 'Сумма освоения без НДС в следующем году'
    column_comment :import_lots, :amount_mastery_nds_next_year, 'Сумма освоения с НДС в следующем году'
  end
end

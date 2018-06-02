class AddOkvedsToImportLots < ActiveRecord::Migration[4.2]
  include MigrationHelper
  def change
    add_column :import_lots, :okved, :string
    add_column :import_lots, :okdp, :string
    add_column :import_lots, :okei, :string
    add_column :import_lots, :okato, :string
    add_column :import_lots, :sme_type, :string
    add_column :import_lots, :is_centralize, :string
    add_column :import_lots, :production_unit, :string

    column_comment :import_lots, :okved, 'Код ОКВЭД2'
    column_comment :import_lots, :okdp, 'Код ОКПД2'
    column_comment :import_lots, :okei, 'Код ОКЕИ'
    column_comment :import_lots, :okato, 'Код ОКАТО'
    column_comment :import_lots, :sme_type, 'Тип МСП'
    column_comment :import_lots, :is_centralize, 'Централизованная закупка?'
    column_comment :import_lots, :production_unit, 'Производственное подразделение'
  end
end

class AddDetailsToTenders < ActiveRecord::Migration[4.2]
  include MigrationHelper
  def change
    add_column :tenders, :agency_contract_date, :date
    add_column :tenders, :agency_contract_num, :string
    column_comment :tenders, :agency_contract_date, 'Дата договора на проведение закупки сторонним организатором'
    column_comment :tenders, :agency_contract_num, 'Номер договора на проведение закупки сторонним организатором'
  end
end

class CreateOkdpSmes < ActiveRecord::Migration[4.2]
  include MigrationHelper
  def change
    create_table :okdp_sme, primary_key: "code", force: true do |t|
    end
    change_column :okdp_sme, :code, :string, limit: 255
    table_comment :okdp_sme, 'Коды ОКПД2 для МСП'
    column_comment :okdp_sme, :code, 'код ОКПД2'
  end
end

class CreateOkdpSmeEtps < ActiveRecord::Migration[4.2]
  include MigrationHelper
  def change
    create_table :okdp_sme_etps, comment: 'Кода ОКДП для МСП и ЕТП' do |t|
      t.string :code, comment: 'Код ОКДП', null: false
      t.string :okdp_type, comment: 'Тип ОКДП', null: false
      t.timestamps null: false
    end

    add_index :okdp_sme_etps, [:id, :code], unique: true

    if oracle_adapter?
      execute <<-SQL
        insert into okdp_sme_etps (id, code, okdp_type, created_at, updated_at)
          select okdp_sme_etps_seq.nextval as id, code, 'МСП' as okdp_type, SYSDATE as created_at, SYSDATE as updated_at from okdp_sme
      SQL
      execute <<-SQL
        insert into okdp_sme_etps (id, code, okdp_type, created_at, updated_at)
          select okdp_sme_etps_seq.nextval as id, code, 'ЭТП' as okdp_type, SYSDATE as created_at, SYSDATE as updated_at from okdp_etp
      SQL
    else
      execute <<-SQL
        insert into okdp_sme_etps (code, okdp_type, created_at, updated_at)
          select code, 'МСП' as okdp_type, CURRENT_DATE as created_at, CURRENT_DATE as updated_at from okdp_sme
      SQL
      execute <<-SQL
        insert into okdp_sme_etps (code, okdp_type, created_at, updated_at)
          select code, 'ЭТП' as okdp_type, CURRENT_DATE as created_at, CURRENT_DATE as updated_at from okdp_etp
      SQL
    end
  end
end

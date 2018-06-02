class ChangeEtpNumFromTenders < ActiveRecord::Migration[4.2]
  include MigrationHelper
  def up
    rev_block { change_column :tenders, :etp_num, :string, limit: 255 }
  end

  def down
    type = oracle_adapter? ? 'integer' : 'int8 USING CAST(etp_num AS int8)'
    rev_block { change_column :tenders, :etp_num, type }
  end

  def rev_block(&block)
    if oracle_adapter?
      add_column :tenders, :etp_num2, :string
      Tender.update_all("etp_num2 = etp_num")
      Tender.update_all("etp_num = null")
    end
    yield
    if oracle_adapter?
      Tender.update_all("etp_num = etp_num2")
      remove_column :tenders, :etp_num2
    end
  end
end

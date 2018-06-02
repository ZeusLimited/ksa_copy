class AddFiasToContacts < ActiveRecord::Migration[4.2]
  include MigrationHelper
  def up
    add_column :contacts, :legal_fias_id, :integer
    column_comment :contacts, :legal_fias_id, 'Юр. адрес ФИАС'

    add_column :contacts, :postal_fias_id, :integer
    column_comment :contacts, :postal_fias_id, 'Почтовый адрес ФИАС'

    update_contacts

    ActiveRecord::Base.connection.execute <<-SQL
      INSERT INTO fias (id, aoid, houseid, name, regioncode, postalcode, okato, oktmo)
      SELECT #{next_sequence_id('fias')},
        aoid, houseid, name, regioncode, postalcode, okato, oktmo
      FROM (
        SELECT
          distinct
          fa.aoid, fh.houseid,
          case when coalesce(fh.postalcode, fa.postalcode) is not null then coalesce(fh.postalcode, fa.postalcode) || ', ' else '' end ||
          fa.fullname || case when fh.houseid is not null then ', д. ' || fh.housenum else '' end ||
                case when fh.buildnum is not null then ' корпус ' || fh.buildnum else '' end ||
                case when fh.strucnum is not null then ' строение ' || fh.strucnum else '' end as name,
          fa.regioncode,
          coalesce(fh.postalcode, fa.postalcode) as postalcode,
          coalesce(fh.okato, fa.okato) as okato,
          coalesce(fh.oktmo, fa.oktmo) as oktmo
        FROM contacts c
          INNER JOIN fias_addrs fa on fa.aoid = c.legal_aoid
          LEFT JOIN  fias_houses fh on fh.houseid = c.legal_houseid
        WHERE c.legal_fias_id is null
      ) sub
    SQL

    update_contacts

    ActiveRecord::Base.connection.execute <<-SQL
      INSERT INTO fias (id, aoid, houseid, name, regioncode, postalcode, okato, oktmo)
      SELECT #{next_sequence_id('fias')},
        aoid, houseid, name, regioncode, postalcode, okato, oktmo
      FROM (
        SELECT
          distinct
          fa.aoid, fh.houseid,
          case when coalesce(fh.postalcode, fa.postalcode) is not null then coalesce(fh.postalcode, fa.postalcode) || ', ' else '' end ||
          fa.fullname || case when fh.houseid is not null then ', д. ' || fh.housenum else '' end ||
                case when fh.buildnum is not null then ' корпус ' || fh.buildnum else '' end ||
                case when fh.strucnum is not null then ' строение ' || fh.strucnum else '' end as name,
          fa.regioncode,
          coalesce(fh.postalcode, fa.postalcode) as postalcode,
          coalesce(fh.okato, fa.okato) as okato,
          coalesce(fh.oktmo, fa.oktmo) as oktmo
        FROM contacts c
          INNER JOIN fias_addrs fa on fa.aoid = c.postal_aoid
          LEFT JOIN  fias_houses fh on fh.houseid = c.postal_houseid
        WHERE c.postal_fias_id is null
     ) sub
    SQL

    update_contacts

    remove_column :contacts, :legal_aoid
    remove_column :contacts, :legal_houseid
    remove_column :contacts, :postal_aoid
    remove_column :contacts, :postal_houseid
  end

  def down
    add_guid_column :contacts, :legal_aoid
    add_guid_column :contacts, :legal_houseid
    add_guid_column :contacts, :postal_aoid
    add_guid_column :contacts, :postal_houseid

    column_comment :contacts, :legal_aoid, 'Юридический адрес'
    column_comment :contacts, :legal_houseid, '№ дома'
    column_comment :contacts, :postal_aoid, 'Почтовый адрес'
    column_comment :contacts, :postal_houseid, '№ дома'

    ActiveRecord::Base.connection.execute <<-SQL
      UPDATE contacts
      SET (legal_aoid, legal_houseid) = (select aoid, houseid from fias where id = contacts.legal_fias_id),
          (postal_aoid, postal_houseid) = (select aoid, houseid from fias where id = contacts.postal_fias_id)
    SQL

    remove_column :contacts, :legal_fias_id
    remove_column :contacts, :postal_fias_id
  end

  private

  def update_contacts
    ['legal', 'postal'].each do |prefix|
      if oracle_adapter?
        ActiveRecord::Base.connection.execute <<-SQL
          UPDATE contacts fps
          SET #{prefix}_fias_id = (SELECT
                          id
                         FROM fias f
                         WHERE f.aoid = fps.legal_aoid
                           and nvl(f.houseid, hextoraw('FF')) = nvl(fps.#{prefix}_houseid, hextoraw('FF')))
          WHERE #{prefix}_fias_id is null
        SQL
      else
        ActiveRecord::Base.connection.execute <<-SQL
          UPDATE contacts fps
          SET #{prefix}_fias_id = (SELECT
                          id
                         FROM fias f
                         WHERE f.aoid = fps.legal_aoid
                           and coalesce(f.houseid, '023ebdf4-adb2-4a79-9dd9-2c478e20ec34') = coalesce(fps.#{prefix}_houseid, '023ebdf4-adb2-4a79-9dd9-2c478e20ec34'))
          WHERE #{prefix}_fias_id is null
        SQL
      end
    end
  end
end

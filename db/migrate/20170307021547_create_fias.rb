class CreateFias < ActiveRecord::Migration[4.2]
  include MigrationHelper
  def up
    create_table :fias, comment: 'Адреса ФИАС' do |t|
      guid_column t, :aoid, comment: 'ФИАС идентификатор адресного объекта'
      guid_column t, :houseid, comment: 'ФИАС идентификатор дома'
      t.string :name, limit: 1000, comment: 'Наименование'
      t.string :regioncode, limit: 2, comment: 'Регион'
      t.string :postalcode, limit: 6, comment: 'Почтовый индекс'
      t.string :okato, limit: 11, comment: 'ОКАТО'
      t.string :oktmo, limit: 11, comment: 'ОКТМО'
    end

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
        FROM fias_plan_specifications fps
          INNER JOIN fias_addrs fa on fa.aoid = fps.addr_aoid
          LEFT JOIN  fias_houses fh on fh.houseid = fps.houseid
      ) sub
    SQL

    add_column :fias_plan_specifications, :fias_id, :integer
    column_comment :fias_plan_specifications, :fias_id, 'ФИАС'

    add_column :fias_specifications, :fias_id, :integer
    column_comment :fias_specifications, :fias_id, 'ФИАС'

    ['fias_plan_specifications', 'fias_specifications'].each do |table_name|
      if oracle_adapter?
        ActiveRecord::Base.connection.execute <<-SQL
          UPDATE #{table_name} fps
          SET fias_id = (SELECT
                          id
                         FROM fias f
                         WHERE f.aoid = fps.addr_aoid
                           and nvl(f.houseid, hextoraw('FF')) = nvl(fps.houseid, hextoraw('FF')))
        SQL
      else
        ActiveRecord::Base.connection.execute <<-SQL
          UPDATE #{table_name} fps
          SET fias_id = (SELECT
                          id
                         FROM fias f
                         WHERE f.aoid = fps.addr_aoid
                           and coalesce(f.houseid, '023ebdf4-adb2-4a79-9dd9-2c478e20ec34') = coalesce(fps.houseid, '023ebdf4-adb2-4a79-9dd9-2c478e20ec34'))
        SQL
      end
    end
  end

  def down
    drop_table :fias
    remove_column :fias_plan_specifications, :fias_id
    remove_column :fias_specifications, :fias_id
  end
end

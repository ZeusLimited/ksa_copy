# frozen_string_literal: true

class CreateEisPlanLots < ActiveRecord::Migration[5.1]
  def change
    create_table :eis_plan_lots do |t|
      t.uuid :plan_lot_guid
      t.integer :year
      t.string :num

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute <<-SQL
          INSERT INTO eis_plan_lots (plan_lot_guid, year, num, created_at, updated_at)
          SELECT
            distinct
            guid,
            extract(year from announce_date) as announce_year,
            first_value(pl.id) over (partition by pl.guid, extract(year from announce_date) order by pl.created_at, pl.id) as eis_num,
            now() at time zone 'GMT',
            now() at time zone 'GMT'
          FROM plan_lots pl
        SQL
      end
    end

    add_index :eis_plan_lots, :plan_lot_guid, name: 'i_eis_plan_lots_guid'
    add_index :eis_plan_lots, :num, name: 'i_eis_plan_lots_num'
  end
end

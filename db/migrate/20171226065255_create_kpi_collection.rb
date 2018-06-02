# frozen_string_literal: true

class CreateKpiCollection < ActiveRecord::Migration[5.1]
  def up
    execute 'CREATE SCHEMA statistic'
    create_table 'statistic.annual_kpis' do |t|
      t.integer :customer_id, null: false
      t.integer :gkpz_year, null: false
      t.integer :year, null: false
      t.integer :month, null: true
      t.decimal :cost, null: false
      t.decimal :cost_nds, null: false
      t.decimal :etp_cost, null: false
      t.decimal :etp_cost_nds, null: false
      t.decimal :auction_cost, null: false
      t.decimal :auction_cost_nds, null: false
      t.decimal :single_source_cost, null: false
      t.decimal :single_source_cost_nds, null: false
      t.decimal :msp_cost, null: false
      t.decimal :msp_cost_nds, null: false
      t.decimal :submsp_cost, null: false
      t.decimal :submsp_cost_nds, null: false
      t.integer :type_name, null: false
      t.timestamps
    end
  end

  def down
    drop_table 'statistic.annual_kpis'
    execute 'DROP SCHEMA statistic'
  end
end

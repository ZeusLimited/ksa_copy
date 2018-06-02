# frozen_string_literal: true

class ProtocolPlanLotsTmp < ApplicationRecord
  self.primary_key = nil
  self.table_name = "protocol_plan_lots_tmp"

  def self.create_unless_exists
    return if oracle_adapter?
    connection.execute <<-SQL
      CREATE TEMPORARY TABLE protocol_plan_lots_tmp (
        user_id integer,
        plan_lot_id integer,
        status_id integer,
        is_plan boolean
      )
      ON COMMIT DROP
    SQL
  end
end

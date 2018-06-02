# frozen_string_literal: true

class Fias < ApplicationRecord
  self.table_name = "fias"

  hex_fields :aoid, :houseid

  scope :by_ids, (lambda do |aoid, houseid = nil|
    guid_eq(:aoid, aoid).guid_eq(:houseid, houseid)
  end)
end

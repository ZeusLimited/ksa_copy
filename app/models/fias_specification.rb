# frozen_string_literal: true

class FiasSpecification < ApplicationRecord
  has_paper_trail

  belongs_to :specification
  belongs_to :fias

  hex_fields :addr_aoid, :houseid

  delegate :name, :okato, :oktmo, :postalcode, to: :fias, prefix: true, allow_nil: true
end

# frozen_string_literal: true

class FiasPlanSpecification < ApplicationRecord
  has_paper_trail

  hex_fields :addr_aoid, :houseid

  belongs_to :plan_specification
  belongs_to :fias

  validates :fias_name, presence: { message: :not_exist }
  validates :fias_okato, presence: { message: :non_okato }

  delegate :name, :okato, :oktmo, :postalcode, to: :fias, prefix: true, allow_nil: true
end

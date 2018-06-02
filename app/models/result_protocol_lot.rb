# frozen_string_literal: true

class ResultProtocolLot < ApplicationRecord
  has_paper_trail

  belongs_to :result_protocol
  belongs_to :lot

  attr_accessor :enable

  delegate :num, :name, :name_with_cust, :specs_cost, :status_id, to: :lot, prefix: true
end

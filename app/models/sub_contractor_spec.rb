# frozen_string_literal: true

class SubContractorSpec < ApplicationRecord
  has_paper_trail

  belongs_to :specification
  belongs_to :contract_specification
  belongs_to :sub_contractor

  delegate :fullname, to: :specification, prefix: true

  money_fields :cost, :cost_nds
end

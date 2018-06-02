# frozen_string_literal: true

class ContractFile < ApplicationRecord
  has_paper_trail

  belongs_to :contract
  belongs_to :tender_file
  belongs_to :file_type, class_name: 'Dictionary'

  delegate :name, to: :file_type, prefix: true
  delegate :document, to: :tender_file, prefix: true, allow_nil: true
end

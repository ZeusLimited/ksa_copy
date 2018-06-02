# frozen_string_literal: true

class ContractorFile < ApplicationRecord
  has_paper_trail

  belongs_to :contractor
  belongs_to :tender_file
  belongs_to :file_type, class_name: "Dictionary", foreign_key: "file_type_id"

  delegate :name, to: :file_type, prefix: true
  delegate :document, to: :tender_file, prefix: true, allow_nil: true
end

# frozen_string_literal: true

class PlanLotsFile < ApplicationRecord
  has_paper_trail

  include Constants

  belongs_to :file_type, class_name: "Dictionary", foreign_key: "file_type_id"
  belongs_to :plan_lot
  belongs_to :tender_file

  delegate :user_id, to: :tender_file, prefix: true
  delegate :document, to: :tender_file, prefix: true, allow_nil: true

  def nmcd?
    file_type_id == FileType::NMCD
  end
end

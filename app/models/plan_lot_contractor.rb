# frozen_string_literal: true

class PlanLotContractor < ApplicationRecord
  include Constants
  has_paper_trail

  belongs_to :contractor
  belongs_to :plan_lot

  delegate :name_short, :name_long, :is_sme, :sme_in_plan?, to: :contractor, prefix: true
  delegate :sme_type_id, to: :plan_lot, prefix: true, allow_nil: true

  validates :contractor_id, presence: true
  validate :sme_contractor

  private

  def sme_contractor
    return unless contractor_id && plan_lot_sme_type_id && plan_lot_sme_type_id == SmeTypes::SME
    errors.add(:contractor_id, :non_sme) unless contractor_sme_in_plan?
  end

end

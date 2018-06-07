# frozen_string_literal: true

module PlanLotValidationRaoesv
  extend ActiveSupport::Concern
  include Constants

  included do
    validates :sme_type_id, absence: true, if: :tender_type_non_sme?
    validate :valid_sme_costs
  end

  private

  def valid_sme_costs
    return if plan_specifications.empty? ||
              sme_type_id != SmeTypes::SME ||
              TenderTypes::FRAMES.include?(tender_type_id)
    errors.add(:sme_type_id, :non_sme_cost_200) if plan_specifications.map(&:total_cost).sum > 200_000_000
  end
end

# frozen_string_literal: true

class DraftOpinion < ApplicationRecord
  has_paper_trail

  belongs_to :offer
  belongs_to :expert
  belongs_to :draft_criterion, class_name: 'TenderDraftCriterion', foreign_key: 'criterion_id'

  delegate :name, to: :draft_criterion, prefix: true

  validates :expert_id, :offer_id, :criterion_id, presence: true

  def self.get_or_new(criterion_id, expert_id, offer_id)
    record = where(criterion_id: criterion_id).where(expert_id: expert_id).where(offer_id: offer_id).first
    record ? record : new(criterion_id: criterion_id, expert_id: expert_id, offer_id: offer_id)
  end
end

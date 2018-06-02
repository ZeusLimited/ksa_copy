# frozen_string_literal: true

class TenderDraftCriterion < ApplicationRecord
  has_paper_trail

  has_and_belongs_to_many :destinations, join_table: "dests_tender_draft_crits", class_name: 'Dictionary'
  belongs_to :tender

  scope :current, ->(dests) { where("id in (select tender_draft_criterion_id from dests_tender_draft_crits where dictionary_id in (?))", dests) }
end

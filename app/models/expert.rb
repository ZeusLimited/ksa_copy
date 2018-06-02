# frozen_string_literal: true

class Expert < ApplicationRecord
  has_paper_trail

  belongs_to :tender
  belongs_to :user

  has_many :draft_opinions, dependent: :destroy

  validates :user_id, presence: true

  has_and_belongs_to_many :destinations, join_table: "dests_experts",
                                         class_name: 'Dictionary', association_foreign_key: 'destination_id'

  scope :current, ->(tender_id, user_id) { where(tender_id: tender_id).where(user_id: user_id) }

  delegate :fio_full, :surname, :fio_short, to: :user, prefix: true, allow_nil: true

  scope :for_index, (lambda do
    includes(:user, :destinations)
    .references(:user)
    .as_json(methods: :destination_names, include: [user: { methods: [:fio_full, :email] }])
  end)

  def destination_names
    destinations.map(&:name).join(', ')
  end

  def current_destinations
    destinations.pluck(:ref_id)
  end
end

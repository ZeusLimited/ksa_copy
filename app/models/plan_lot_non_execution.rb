# frozen_string_literal: true

class PlanLotNonExecution < ApplicationRecord
  belongs_to :user

  scope :all_versions, ->(hex) { where(:plan_lot_guid, hex).order(:created_at) }

  validates :reason, presence: true

  hex_fields :plan_lot_guid

  delegate :fio_full, to: :user, prefix: true

  def sign
    "#{created_at} #{user_fio_full}"
  end
end

# frozen_string_literal: true

class ControlPlanLot < ApplicationRecord
  has_paper_trail

  belongs_to :user

  validates :plan_lot_guid, uniqueness: true

  delegate :fio_short, to: :user, prefix: true

  hex_fields :plan_lot_guid

  def self.create_list(current_user)
    current_user.plan_lots.pluck(:guid).each do |guid|
      control_plan_lot = new(user: current_user, plan_lot_guid: guid)
      next unless control_plan_lot.valid?
      control_plan_lot.save
    end
  end

  def self.delete_list(current_user)
    where(plan_lot_guid: current_user.plan_lots.select('plan_lots.guid')).each(&:destroy)
  end
end

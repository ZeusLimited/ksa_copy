# frozen_string_literal: true

class Subscribe < ApplicationRecord
  include Constants
  has_many :actual_subscribes
  has_many :subscribe_actions, dependent: :destroy
  accepts_nested_attributes_for :subscribe_actions, allow_destroy: true

  has_many :subscribe_warnings, class_name: 'SubscribeAction'
  accepts_nested_attributes_for :subscribe_warnings,
                                allow_destroy: true,
                                reject_if: proc { |attribute| attribute[:days_before].blank? }

  belongs_to :plan_lot, -> { where(version: 0).eager_load(PlanFilter::REQUIRED_ASSOCIATIONS) },
             foreign_key: 'plan_lot_guid',
             primary_key: 'guid'

  scope :for_action, (lambda do |action_id, days|
    joins(:actual_subscribes)
      .where(actual_subscribes: { action_id: action_id, days_before: days })
  end)

  validates :plan_lot_guid, uniqueness: { scope: :user_id }

  delegate :full_num, :title, :gkpz_year, :tender_type_name, :root_customer_fullname, :root_customer_shortname, to: :plan_lot, prefix: true
  delegate :lot_name, to: :plan_lot, prefix: false
  delegate :tender, to: :lot, prefix: true, allow_nil: true

  hex_fields :plan_lot_guid

  class << self
    def generate_list(current_user)
      current_user.plan_lots.map do |plan_lot|
        current_user.subscribe(plan_lot.guid) || current_user.subscribes.build(lot_info(plan_lot))
      end
    end

    def lot_info(plan_lot)
      { plan_lot_guid: plan_lot.guid,
        plan_structure: plan_lot.to_struct,
        fact_structure: Lot.last_public(plan_lot.guid_hex).last.try(:tender_to_struct) }
    end
  end

  def clear_update(actions)
    subscribe_actions.delete_all
    subscribe_warnings.delete_all
    update(actions)
  end

  def plan_lot_exists?
    PlanLot.guid_eq(:guid, plan_lot_guid_hex).exists?
  end

  def plan_object
    parse_json(plan_structure)
  end

  def fact_object
    parse_json(fact_structure)
  end

  def lot
    Lot.last_public(plan_lot_guid_hex).last
  end

  def update_structures
    return unless plan_lot_exists?
    self.plan_structure = plan_lot.to_struct
    self.fact_structure = Lot.last_public(plan_lot.guid_hex).last.try(:tender_to_struct)
    save
  end

  private

  def parse_json(json_string)
    return if json_string.nil?
    JSON.parse(json_string)
  rescue JSON::ParserError
    return nil
  end
end

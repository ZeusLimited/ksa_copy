# frozen_string_literal: true

class SubscribeAction < ApplicationRecord
  include Constants
  belongs_to :action, class_name: 'Dictionary'
  belongs_to :subscribe

  has_one :plan_lot, through: :subscribe

  delegate :name, to: :action, prefix: true
  delegate :plan_object, :fact_object, to: :subscribe, prefix: true, allow_nil: true

  delegate :guid_hex, to: :plan_lot, prefix: true, allow_nil: true
  delegate :lot, :plan_lot_guid_hex, to: :subscribe, prefix: true, allow_nil: true

  def occur_and_save
    ActualSubscribe.create(subscribe_id: subscribe_id, action_id: action_id, days_before: days_to) if occur?
  end

  private

  def occur?
    case action_id
    when SubscribeActions::CONFIRM        then plan_protocol_with?(PlanLotStatus::AGREEMENT)
    when SubscribeActions::CANCEL_PLAN    then plan_protocol_with?(PlanLotStatus::CANCELED)
    when SubscribeActions::CONFIRM_SD     then plan_protocol_with?(PlanLotStatus::CONFIRM_SD)
    when SubscribeActions::EXCLUDED_SD    then plan_protocol_with?(PlanLotStatus::EXCLUDED_SD)
    when SubscribeActions::PUBLIC         then public?
    when SubscribeActions::OPEN           then open?
    when SubscribeActions::REVIEW         then review?(LotStatus::REVIEW)
    when SubscribeActions::REVIEW_CONFIRM then review?(LotStatus::REVIEW_CONFIRM)
    when SubscribeActions::REOPEN         then reopen?
    when SubscribeActions::WINNER         then winner_protocol?(LotStatus::SW)
    when SubscribeActions::WINNER_CONFIRM then winner_protocol?(LotStatus::SW_CONFIRM)
    when SubscribeActions::RESULT         then result_protocol?
    when SubscribeActions::CONTRACT       then complete?(LotStatus::CONTRACT)
    when SubscribeActions::FAIL           then complete?(LotStatus::FAIL)
    when SubscribeActions::CANCEL         then complete?(LotStatus::CANCEL)
    when SubscribeActions::DELETE         then subscribe.plan_lot_exists?
    when SubscribeWarnings::PUBLIC        then warning_public?
    when SubscribeWarnings::OPEN          then warning_open?
    when SubscribeWarnings::SUMMARIZE     then warning_summarized?
    else false
    end
  end

  def lot_attribute(attribute)
    return if subscribe_fact_object.blank?
    fact_lot = subscribe_fact_object["lots"].find do |l|
      plan_lot.all_versions.pluck(:id).include?(l["plan_lot_id"])
    end
    fact_lot && fact_lot[attribute]
  end

  def warning_public?
    days_to_public.between?(0, days_before)
  end

  def warning_open?
    days_to_open.between?(0, days_before) if days_to_open
  end

  def warning_summarized?
    days_to_summary.between?(0, days_before) if days_to_summary
  end

  def days_to
    case action_id
    when SubscribeWarnings::PUBLIC then
      days_to_public
    when SubscribeWarnings::OPEN then
      days_to_open
    when SubscribeWarnings::SUMMARIZE then
      days_to_summary
    end
  end

  def days_to_public
    (Date.parse(subscribe_plan_object["announce_date"]) - Date.current).to_i
  end

  def days_to_open
    return unless subscribe_fact_object
    (Date.parse(subscribe_fact_object["bid_date"]) - Date.current).to_i
  end

  def days_to_summary
    return unless subscribe_fact_object
    (Date.parse(subscribe_fact_object["summary_date"]) - Date.current).to_i
  end

  def plan_protocol_with?(pl_status)
    return unless subscribe.plan_lot_exists?
    PlanLot
      .joins(:protocol)
      .guid_eq(:guid, subscribe_plan_lot_guid_hex)
      .where("plan_lots.created_at >= ?", Time.parse(subscribe_plan_object["created_at"]) + 1.second)
      .where(status_id: pl_status)
      .exists?
  end

  def confirm_plan?
    return unless subscribe.plan_lot_exists?
    PlanLot
      .joins(:protocol)
      .guid_eq(:guid, plan_lot_guid_hex)
      .where("plan_lots.created_at >= ?", Time.parse(subscribe_plan_object["created_at"]) + 1.second)
      .exists?
  end


  def public?
    return unless subscribe_lot && subscribe_lot.status_id >= LotStatus::PUBLIC
    check_structure || lot_attribute("status_id") == LotStatus::NEW
  end

  def open?
    return unless subscribe_lot && subscribe_lot.open_protocol && subscribe_lot.status_id >= LotStatus::OPEN
    check_structure || lot_attribute("status_id") < LotStatus::OPEN
  end

  def review?(status)
    return unless subscribe_lot && subscribe_lot.review_protocol && subscribe_lot.status_id >= status
    check_structure || lot_attribute("status_id") < status
  end

  def reopen?
    return unless subscribe_lot && subscribe_lot.rebid_protocol && subscribe_lot.status_id >= LotStatus::REOPEN
    check_structure || lot_attribute("status_id") < LotStatus::REOPEN
  end

  def winner_protocol?(status)
    return unless subscribe_lot && subscribe_lot.winner_protocol && subscribe_lot.status_id >= status
    check_structure || lot_attribute("status_id") < status
  end

  def result_protocol?
    return unless subscribe_lot && subscribe_lot.result_protocol && subscribe_lot.status_id >= LotStatus::RP_SIGN
    check_structure || [LotStatus::CONTRACT, LotStatus::RP_SIGN].exclude?(lot_attribute("status_id"))
  end

  def complete?(status)
    return unless subscribe_lot && subscribe_lot.status_id == status
    check_structure || lot_attribute("status_id") != status
  end

  def check_structure
    subscribe_fact_object.nil? || lot_attribute("id") != subscribe_lot.id
  end
end

# frozen_string_literal: true

class ActualSubscribe < ApplicationRecord
  self.primary_key = nil
  include Constants
  belongs_to :action, class_name: 'Dictionary'

  delegate :name, to: :action, prefix: true

  def link_to_plan?
    @link_to_plan ||= [
      SubscribeActions::CONFIRM,
      SubscribeActions::CANCEL_PLAN,
      SubscribeActions::CONFIRM_SD,
      SubscribeActions::EXCLUDED_SD,
      SubscribeWarnings::PUBLIC
    ].include?(action_id)
  end

  def self.create_unless_exists
    return if oracle_adapter?
    connection.execute <<-SQL
      CREATE TEMPORARY TABLE actual_subscribes (
        subscribe_id integer NOT NULL,
        action_id integer NOT NULL,
        days_before integer
      )
      ON COMMIT DROP
    SQL
  end
end

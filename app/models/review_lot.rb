# frozen_string_literal: true

class ReviewLot < ApplicationRecord
  include Constants
  has_paper_trail

  belongs_to :lot
  belongs_to :review_protocol

  validates :rebid_date, :rebid_place, presence: true, if: proc { |r| r.rebid.to_b }
  validate :valid_rebid_date
  def valid_rebid_date
    return unless rebid_date && review_protocol_confirm_date
    return unless TenderTypes::REBID_1_DAY.include?(lot_tender_type_id) &&
                  rebid_date.to_date < review_protocol_confirm_date + 1.day
    errors.add(:rebid_date, :hours_after_confirm, hours: 24)
  end

  delegate :name, :num, :specs_cost, :status_name, :tender_type_id, :status_id, :name_with_cust, to: :lot, prefix: true
  delegate :status_stylename_html, :nums, to: :lot, prefix: true, allow_nil: true
  delegate :confirm_date, to: :review_protocol, prefix: true
  delegate :plan_lot_control_user_fio_short, :plan_lot_control_created_at, to: :lot, prefix: false, allow_nil: true

  attr_accessor :enable, :rebid

  compound_datetime_fields :rebid_date

  before_save :set_rebid_nil
  def set_rebid_nil
    return if rebid.to_b
    self.rebid_date = nil
    self.rebid_place = nil
  end
end

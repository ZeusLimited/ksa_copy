# frozen_string_literal: true

class ReviewProtocol < ApplicationRecord
  include Constants
  has_paper_trail

  belongs_to :tender

  has_many :review_lots, dependent: :destroy, inverse_of: :review_protocol
  has_many :lots, through: :review_lots

  accepts_nested_attributes_for :review_lots, allow_destroy: true

  after_save :update_review_protocol_for_lots
  after_destroy :update_review_protocol_for_lots

  validates :tender_id, :num, :confirm_date, presence: true
  validates :num, length: { maximum: 255 }
  validates :num, uniqueness: { scope: :tender_id, message: :must_uniq }
  validate :confirm_date_already_use
  validate :confirm_date_less_then_open_date
  validate :must_have_lots
  validates :confirm_date, workday: true

  validates_associated :review_lots

  set_date_columns :confirm_date if oracle_adapter?

  def open_lots?
    lots.in_status(LotStatus::OPEN).exists?
  end

  def review_lots?
    lots.in_status(LotStatus::REVIEW).exists?
  end

  def all_lots_review?
    lots.count == lots.in_status(LotStatus::REVIEW).count
  end

  def all_lots_confirm?
    lots.count == lots.in_status(LotStatus::REVIEW_CONFIRM).count
  end

  def all_lots_open?
    lots.count == lots.in_status(LotStatus::OPEN).count
  end

  def initialized_review_lots # this is the key method
    [].tap do |object|
      array_lots = tender.lots.in_status(Constants::LotStatus::OPEN) + lots
      array_lots.uniq.sort_by(&:num).each do |lot|
        c = review_lots.find { |rl| rl.lot_id == lot.id }
        if c
          object << c.tap do |rl|
            rl.enable ||= true
            rl.rebid ||= rl.rebid_date.present?
          end
        else
          object << ReviewLot.new(lot_id: lot.id, review_protocol_id: id, rebid: true)
        end
      end
    end
  end

  private

  def update_review_protocol_for_lots
    Lot.where(tender_id: tender_id).update_all <<-SQL
      review_protocol_id = (
        SELECT DISTINCT FIRST_VALUE(rp.id) OVER (ORDER BY rp.confirm_date DESC)
        FROM review_lots lrp
        INNER JOIN review_protocols rp ON lrp.review_protocol_id = rp.id
        WHERE lrp.lot_id = lots.id)
    SQL
  end

  def confirm_date_less_then_open_date
    return unless confirm_date && tender && tender.open_protocol && confirm_date < tender.open_protocol_sign_date
    errors.add(:confirm_date, :less_then_open_date, date: tender.open_protocol_sign_date)
  end

  def confirm_date_already_use
    return unless confirm_date
    return if review_lots.empty?

    lot_ids = review_lots.map(&:lot_id)
    confirm_dates = self.class
      .joins("INNER JOIN review_lots lwp ON lwp.review_protocol_id = review_protocols.id")
      .where("lot_id IN (#{lot_ids.join(', ')})")
    confirm_dates = confirm_dates.where.not(id: id) if id
    confirm_dates = confirm_dates.pluck(:confirm_date)

    return unless confirm_dates.include?(confirm_date)
    errors.add(:confirm_date, :confirm_date_already_use)
  end

  def must_have_lots
    errors.add(:base, :must_have_lots) if review_lots.empty? || review_lots.all?(&:_destroy)
  end
end

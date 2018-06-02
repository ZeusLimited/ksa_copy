# frozen_string_literal: true

class WinnerProtocol < ApplicationRecord
  include Constants
  has_paper_trail

  belongs_to :tender
  has_many :winner_protocol_lots, validate: false, dependent: :destroy
  has_many :lots, through: :winner_protocol_lots, validate: false

  after_save :update_win_protocol_for_lots
  after_destroy :update_win_protocol_for_lots

  validates :num, :confirm_date, presence: true
  validates :num, length: { maximum: 255 }
  validates :num, uniqueness: { scope: :tender_id, message: :must_uniq }
  validate :confirm_date_already_use
  validate :confirm_date_less_then_open_date
  validate :confirm_date_less_then_review_date
  validate :confirm_date_less_then_rebid_date
  validate :must_have_lots
  validates :confirm_date, workday: true
  validates_with NewBidderValidator

  accepts_nested_attributes_for :winner_protocol_lots, allow_destroy: true

  set_date_columns :confirm_date if oracle_adapter?

  delegate :tender_type_id, to: :tender, prefix: false

  def initialized_winner_protocol_lots # this is the key method
    [].tap do |object|
      available_lots.each do |lot|
        c = winner_protocol_lots.find { |wl| wl.lot_id == lot.id }
        object << if c
                    c.tap { |wl| wl.enable ||= true }
                  else
                    WinnerProtocolLot.new(lot_id: lot.id, winner_protocol_id: id)
                  end
      end
    end
  end

  def available_lots
    (tender.lots.for_winner_protocol + lots).uniq.sort_by(&:num)
  end

  def reopen_lots?
    lots.in_status(LotStatus::FOR_WP).exists?
  end

  def win_lots?
    lots.in_status(LotStatus::SW).exists?
  end

  def confirm_lots?
    lots.in_status(LotStatus::SW_CONFIRM).exists?
  end

  def all_lots_win?
    lots.count == lots.in_status(LotStatus::SW).count
  end

  def all_lots_confirm?
    lots.count == lots.in_status(LotStatus::SW_CONFIRM).count
  end

  def all_lots_sign_or_fail?
    lots.count == lots.in_status([LotStatus::WINNER, LotStatus::FAIL, LotStatus::CANCEL]).count
  end

  def all_lots_before_pre_confirm?
    lots.count == lots.in_status(LotStatus::FOR_WP).count
  end

  def name
    "Протокол №#{num} от #{confirm_date}"
  end

  validate :valid_check_msp_offerts
  def valid_check_msp_offerts
    return unless Offer.actuals
                       .joins(:lot, bidder: :contractor)
                       .where(lot_id: winner_protocol_lots.map(&:lot_id))
                       .where.not(status_id: OfferStatuses::REJECT)
                       .where(lots: { sme_type_id: SmeTypes::SME })
                       .where(contractors: { is_sme: false })
                       .exists?
    errors.add(:base, :non_sme)
  end

  private

  def update_win_protocol_for_lots
    Lot.where(tender_id: tender_id).update_all <<-SQL
      winner_protocol_id = (
        SELECT DISTINCT FIRST_VALUE(wp.id) OVER (ORDER BY wp.confirm_date DESC)
        FROM winner_protocol_lots lwp
        INNER JOIN winner_protocols wp ON lwp.winner_protocol_id = wp.id
        WHERE lwp.lot_id = lots.id)
    SQL
    Offer.where(lot_id: winner_protocol_lots.map(&:lot_id))
         .where(status_id: OfferStatuses::NEW)
         .update_all(status_id: OfferStatuses::RECEIVE)
  end

  def confirm_date_less_then_rebid_date
    return unless confirm_date
    winner_protocol_lots.each do |wpl|
      next unless wpl.lot_rebid_protocol_id? && wpl.lot_rebid_protocol_confirm_date > confirm_date
      errors.add(:confirm_date, :less_then_rebid_date,
                 num: wpl.lot_rebid_protocol_num,
                 date: wpl.lot_rebid_protocol_confirm_date)
    end
  end

  def confirm_date_less_then_review_date
    return unless confirm_date
    winner_protocol_lots.each do |wpl|
      next unless wpl.lot_review_protocol_id? && wpl.lot_review_protocol_confirm_date > confirm_date
      errors.add(:confirm_date, :less_then_review_date,
                 num: wpl.lot_review_protocol_num,
                 date: wpl.lot_review_protocol_confirm_date)
    end
  end

  def confirm_date_less_then_open_date
    return unless confirm_date && tender.open_protocol_sign_date
    errors.add(:confirm_date, :less_then_open_date,
               date: tender.open_protocol_sign_date) if confirm_date < tender.open_protocol_sign_date
  end

  def confirm_date_already_use
    return unless confirm_date
    return if lots.empty?
    errors.add(:confirm_date, :already_use) if lots_confirm_dates.include?(confirm_date)
  end

  def must_have_lots
    errors.add(:base, :must_have_lots) if winner_protocol_lots.empty? || winner_protocol_lots.all?(&:_destroy)
  end

  def lots_confirm_dates
    WinnerProtocol
      .joins(:winner_protocol_lots)
      .where(winner_protocol_lots: { lot_id: winner_protocol_lots.map(&:lot_id) })
      .where.not(id: id)
      .pluck(:confirm_date)
  end
end

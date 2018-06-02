# frozen_string_literal: true

class ResultProtocol < ApplicationRecord
  include Constants
  has_paper_trail

  has_many :result_protocol_lots, validate: false, dependent: :destroy
  has_many :lots, through: :result_protocol_lots, validate: false
  belongs_to :tender

  after_save :update_result_protocol_for_lots
  after_destroy :update_result_protocol_for_lots

  validates :num, :sign_date, :sign_city, presence: true
  validates :num, length: { maximum: 255 }
  validates :num, uniqueness: { scope: :tender_id, message: :must_uniq }
  validates :sign_date, workday: true
  validate :sign_date_bigger_or_eq_then_winner_protocol_date
  validate :must_have_lots

  accepts_nested_attributes_for :result_protocol_lots, allow_destroy: true

  set_date_columns :sign_date if oracle_adapter?

  delegate :tender_type_id, to: :tender, prefix: false

  def initialized_result_protocol_lots # this is the key method
    [].tap do |object|
      array_lots = tender.lots.for_result_protocol + lots
      array_lots.uniq.sort_by(&:num).each do |lot|
        c = result_protocol_lots.find { |rl| rl.lot_id == lot.id }
        if c
          object << c.tap { |rl| rl.enable ||= true }
        else
          object << ResultProtocolLot.new(lot_id: lot.id, result_protocol_id: id)
        end
      end
    end
  end

  def winner_lots?
    lots.in_status(LotStatus::WINNER).exists?
  end

  def all_lots_winner?
    lots.count == lots.in_status(LotStatus::WINNER).count
  end

  def all_lots_sign?
    lots.count == lots.in_status(LotStatus::RP_SIGN).count
  end

  private

  def update_result_protocol_for_lots
    Lot.where(tender_id: tender_id).update_all <<-SQL
      result_protocol_id = (
        SELECT DISTINCT FIRST_VALUE(rp.id) OVER (ORDER BY rp.sign_date DESC)
        FROM result_protocol_lots lrp
        INNER JOIN result_protocols rp ON lrp.result_protocol_id = rp.id
        WHERE lrp.lot_id = lots.id)
    SQL
  end

  def sign_date_bigger_or_eq_then_winner_protocol_date
    return unless sign_date
    confirm_dates = Lot.joins(:winner_protocol).where(id: result_protocol_lots.map(&:lot_id)).pluck(:confirm_date)
    if confirm_dates.any? { |cd| cd > sign_date } && Constants::TenderTypes::TENDERS.include?(tender_type_id)
      errors.add(:sign_date, :less_then_winner_date)
    elsif confirm_dates.any? { |cd| cd != sign_date } && Constants::TenderTypes::AUCTIONS.include?(tender_type_id)
      errors.add(:sign_date, :equal_winner_date)
    end
  end

  def sign_date_already_use
    return unless sign_date
    return if lots.empty?

    sign_dates = self.class
      .joins("INNER JOIN result_protocol_lots rpl ON rpl.result_protocol_id = result_protocols.id")
      .where("lot_id IN (#{lot_ids.join(', ')})")
    sign_dates = sign_dates.where.not(id: id) if id
    sign_dates = sign_dates.pluck(:sign_date)

    errors.add(:sign_date, :already_use) if sign_dates.include?(sign_date)
  end

  def must_have_lots
    errors.add(:base, :must_have_lots) if result_protocol_lots.empty? || result_protocol_lots.all?(&:_destroy)
  end
end

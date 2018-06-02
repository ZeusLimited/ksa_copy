# frozen_string_literal: true

class WinnerProtocolLot < ApplicationRecord
  include Constants
  has_paper_trail

  belongs_to :winner_protocol
  belongs_to :lot
  belongs_to :solution_type, class_name: 'Dictionary', foreign_key: 'solution_type_id'
  has_many :review_lots, through: :lot
  has_many :offers, through: :lot

  validates :solution_type_id, presence: true

  delegate :name, :num, :specs_cost, :status_name, :status_id, :name_with_cust, to: :lot, prefix: true
  delegate :review_protocol_id?, :review_protocol_num, :review_protocol_confirm_date, to: :lot, prefix: true
  delegate :rebid_protocol_id?, :rebid_protocol_confirm_date, :rebid_protocol_num, to: :lot, prefix: true
  delegate :status_stylename_html, to: :lot, prefix: true, allow_nil: true
  delegate :name, to: :solution_type, prefix: true, allow_nil: true
  delegate :tender_type_id, to: :lot, prefix: true
  delegate :plan_lot_control_user_fio_short, :plan_lot_control_created_at, to: :lot, prefix: false, allow_nil: true

  attr_accessor :enable

  def solutions
    collection = [WinnerProtocolSolutionTypes::CANCEL]
    collection << WinnerProtocolSolutionTypes::WINNER if win?
    collection << WinnerProtocolSolutionTypes::SINGLE_SOURCE if single_source?
    collection << WinnerProtocolSolutionTypes::FAIL if fail?
    Dictionary.where(ref_id: collection)
  end

  def status_after_sign
    case solution_type_id
    when WinnerProtocolSolutionTypes::CANCEL then LotStatus::CANCEL
    when WinnerProtocolSolutionTypes::FAIL then LotStatus::FAIL
    else LotStatus::WINNER
    end
  end

  def status_before_pre_confirm
    return LotStatus::REOPEN if lot.rebid_protocol
    return LotStatus::REVIEW_CONFIRM if lot.review_protocol
    return LotStatus::OPEN if lot.tender.open_protocol
    LotStatus::PUBLIC
  end

  private

  def win?
    lot_valid_status? &&
      no_rebid? &&
      offers.wins.count >= (lot_tender_type_id == TenderTypes::PO ? 3 : 1) &&
      Bidder.recieves(lot).count >= min_bidders
  end

  def single_source?
    lot_valid_status? &&
      no_rebid? &&
      min_bidders == 2 &&
      offers.wins.count == 1 &&
      Bidder.recieves(lot).count == 1
  end

  def fail?
    lot_valid_status? && !offers.wins.exists? && Bidder.recieves(lot).count < min_bidders
  end

  def lot_valid_status?
    [LotStatus::NEW, LotStatus::PUBLIC, LotStatus::REVIEW].exclude?(lot_status_id)
  end

  def no_rebid?
    !(lot_status_id == LotStatus::REVIEW_CONFIRM && review_lots.last.rebid_date.present?)
  end

  def min_bidders
    @min_bidders ||= case lot_tender_type_id
                     when TenderTypes::ONLY_SOURCE then 1
                     when TenderTypes::UNREGULATED then 1
                     when TenderTypes::ZPP then 1
                     when TenderTypes::PO then 3
                     else 2
                     end
  end
end

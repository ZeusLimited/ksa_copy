# frozen_string_literal: true

class RebidProtocol < ApplicationRecord
  include Constants
  has_paper_trail

  belongs_to :tender
  belongs_to :commission
  belongs_to :clerk, class_name: "User", foreign_key: "clerk_id"

  has_many :lots, -> { order(:num, :sublot_num) }
  has_many :rebid_protocol_present_members, dependent: :destroy
  has_many :rebid_protocol_present_bidders, dependent: :destroy
  has_many :offers, through: :lots
  has_many :bidders, through: :offers
  has_many :plan_lots, through: :lots

  accepts_nested_attributes_for :lots
  accepts_nested_attributes_for :rebid_protocol_present_members, allow_destroy: true
  accepts_nested_attributes_for :rebid_protocol_present_bidders, allow_destroy: true

  delegate :name_r, to: :commission, prefix: true
  delegate :local_time_zone, to: :tender, prefix: true
  delegate :fio_full, :phone, to: :clerk, prefix: true

  set_date_columns :confirm_date if oracle_adapter?
  compound_datetime_fields :rebid_date

  validates :location, :num, :rebid_date, :resolve, :confirm_city, :confirm_date, :clerk_id, presence: true
  validates :confirm_city, :location, length: { maximum: 255 }
  validate :confirm_date_bigger_then_review_date
  validate :confirm_date_bigger_then_open_date
  validate :rebid_date_not_equal_rebid_date_review
  validate :must_have_lots

  after_save :update_lots
  def update_lots
    rebid_lots.each do |rl|
      lot = Lot.find rl['id']
      lot.rebid_protocol_id = rl['selected'].to_b ? id : nil
      lot.status_id = LotStatus::REOPEN if rl['selected'].to_b && lot.status_id == LotStatus::REVIEW_CONFIRM
      lot.status_id = LotStatus::REVIEW_CONFIRM if !rl['selected'].to_b && lot.status_id == LotStatus::REOPEN
      lot.save(validate: false)
    end
  end

  after_destroy :clear_lots
  def clear_lots
    lots.each { |l| l.update_attributes(rebid_protocol_id: nil, status_id: LotStatus::REVIEW_CONFIRM) }
  end

  def clerk_name
    clerk.try(:fio_full)
  end

  def initialized_present_members # this is the key method
    [].tap do |o|
      new_users = commission.commission_users.joins(:user).order("status, surname, name, patronymic")
      new_users.each do |cu|
        c = rebid_protocol_present_members.find { |rppm| rppm.user_id == cu.user_id && rppm.status_id == cu.status }
        if c
          o << c.tap { |rppm| rppm.enable ||= true }
        else
          o << RebidProtocolPresentMember.new(user_id: cu.user_id, status_id: cu.status, rebid_protocol_id: id)
        end
      end
      rebid_protocol_present_members.each do |rppm|
        next if new_users.any? { |c| c.user_id == rppm.user_id && c.status == rppm.status_id }
        o << rppm.tap do |c|
          c.enable = false
          c.hide = true
        end
      end
    end
  end

  # example: rebid_lots = [{"id"=>"903370", "selected"=>"1"}]
  def rebid_lots
    @rebid_lots || []
  end

  def all_lots_review_confirm?
    lots.count == lots.in_status(LotStatus::REVIEW_CONFIRM).count
  end

  def all_lots_reopen?
    lots.count == lots.in_status(LotStatus::REOPEN).count
  end

  def all_lots_public?
    lots.count == lots.in_status(LotStatus::PUBLIC).count
  end

  def confirm_date_bigger_then_review_date
    return unless confirm_date
    tender.lots.each do |lot|
      next unless lot.review_protocol && lot_select?(lot) && lot.review_protocol_confirm_date > confirm_date
      errors.add(:confirm_date, :less_then_review_date, num: lot.review_protocol_num, date: lot.review_protocol_confirm_date)
    end
  end

  def confirm_date_bigger_then_open_date
    return unless confirm_date && tender.open_protocol && confirm_date < tender.open_protocol_sign_date
    errors.add(:confirm_date, :less_then_open_date, date: tender.open_protocol_sign_date)
  end

  def rebid_date_not_equal_rebid_date_review
    rebid_lots.each do |lot|
      next unless lot['selected'] == "1"
      time = ReviewLot.where(lot_id: lot['id'],
                             review_protocol_id: Lot.find(lot['id']).review_protocol_id).take.rebid_date
      next if rebid_date == time
      errors.add(:rebid_date, :not_equal_rebid_date_review, time: time.strftime("%d.%m.%Y %H:%M"))
    end
  end

  attr_writer :rebid_lots

  def rebid_lots_attributes=(attributes)
    @rebid_lots = attributes.values
  end

  def lot_select?(lot)
    return false if rebid_lots.empty?
    rl = rebid_lots.find { |l| l['id'] == lot.id.to_s }
    return false if rl.nil?
    rl['selected'] == '1'
  end

  def must_have_lots
    errors.add(:base, :must_have_lots) if rebid_lots.empty? || rebid_lots.all? { |rl| !rl['selected'].to_b }
  end
end

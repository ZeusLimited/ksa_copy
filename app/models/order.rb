# frozen_string_literal: true

class Order < ApplicationRecord
  belongs_to :agreed_by, class_name: 'User', foreign_key: 'agreed_by_user_id'
  belongs_to :received_from, class_name: 'User', foreign_key: 'received_from_user_id'
  has_many :lots, dependent: :restrict_with_error
  has_and_belongs_to_many :plan_lots
  has_many :order_files

  delegate :fio_full, to: :received_from, prefix: true, allow_nil: true
  delegate :fio_full, to: :agreed_by, prefix: true, allow_nil: true

  before_validation :set_agreed_by

  accepts_nested_attributes_for :order_files, allow_destroy: true

  set_date_columns :receiving_date, :agreement_date if oracle_adapter?

  validates :num, :receiving_date, :received_from_user_id, presence: true

  validate :check_dates, if: :agreement_date
  def check_dates
    return if agreement_date >= receiving_date
    errors.add(:agreement_date, :must_be_greater)
  end

  validate :check_agreed_user, if: :agreement_date
  def check_agreed_user
    return if agreed_by
    errors.add(:agreed_by, :must_be_agreed_user)
  end

  validate :check_order_uniqness
  def check_order_uniqness
    fault_plan_lots = []
    plan_lots.each do |pl|
      fault_plan_lots << "#{pl.num_tender}.#{pl.num_lot}" if pl.all_orders.where(num: self.num).where.not(id: self.id).exists?
    end
    errors.add(:base, :must_be_uniq, lots: fault_plan_lots.join(', ')) unless fault_plan_lots.empty?
  end

  def root_customer_names
    plan_lots.map(&:root_customer_name).uniq.join(', ')
  end

  def confirmed?
    (agreement_date && agreed_by_user_id).present?
  end

  def save_with_plan_lots(current_user)
    plan_lots << current_user.plan_lots
    save
  end

  def set_params(current_user)
    self.received_from_user_id = current_user.id
    self.agreed_by_user_id = current_user.id
    self.plan_lots = current_user.plan_lots
  end

  private

  def set_agreed_by
    self.agreed_by = nil if agreement_date.nil?
  end
end

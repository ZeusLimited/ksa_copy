# frozen_string_literal: true

class OpenProtocol < ApplicationRecord
  validates_with NewBidderValidator
  has_paper_trail

  belongs_to :tender
  belongs_to :commission
  belongs_to :clerk, class_name: "User", foreign_key: "clerk_id"

  has_many :open_protocol_present_members, dependent: :destroy
  has_many :open_protocol_present_bidders, dependent: :destroy

  accepts_nested_attributes_for :open_protocol_present_members, allow_destroy: true
  accepts_nested_attributes_for :open_protocol_present_bidders, allow_destroy: true

  set_date_columns :sign_date if oracle_adapter?
  compound_datetime_fields :open_date

  validates :num, :open_date, :sign_date, presence: true
  validates :location, :resolve, :sign_city, :clerk_id, presence: true, unless: proc { |op| op.tender_noncompetitive? }
  validates :sign_city, :location, length: { maximum: 255 }
  validates :tender_id, uniqueness: true

  delegate :name_r, to: :commission, prefix: true, allow_nil: true
  delegate :fio_full, :phone, to: :clerk, prefix: true, allow_nil: true
  delegate :bid_date, :local_bid_date, :local_time_zone, :only_source?, :noncompetitive?, to: :tender, prefix: true

  def clerk_name
    clerk.try(:fio_full)
  end

  def initialized_present_members # this is the key method
    [].tap do |o|
      new_users = commission.commission_users.joins(:user).order("status, surname, name, patronymic")
      new_users.each do |cu|
        c = open_protocol_present_members.find { |oppm| oppm.user_id == cu.user_id && oppm.status_id == cu.status }
        if c
          o << c.tap { |oppm| oppm.enable ||= true }
        else
          o << OpenProtocolPresentMember.new(user_id: cu.user_id, status_id: cu.status, open_protocol_id: id)
        end
      end
      open_protocol_present_members.each do |oppm|
        next if new_users.any? { |c| c.user_id == oppm.user_id && c.status == oppm.status_id }
        o << oppm.tap do |c|
          c.enable = false
          c.hide = true
        end
      end
    end
  end
end

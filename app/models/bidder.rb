# frozen_string_literal: true

class Bidder < ApplicationRecord
  include Constants
  has_paper_trail

  belongs_to :tender
  belongs_to :contractor

  has_many :covers, -> { order("register_time") }, dependent: :destroy
  has_many :offers, dependent: :delete_all
  has_many :bidder_files, -> { order(:id) }, dependent: :destroy
  has_many :tender_files, through: :bidder_files
  has_many :open_protocol_present_bidders, dependent: :destroy
  has_many :rebid_protocol_present_bidders, dependent: :destroy

  delegate :legal_addr, :name_short, :name_inn, :name_long, to: :contractor, prefix: true, allow_nil: true
  delegate :is_sme, :sme_type_id, :orig?, :guid_hex, to: :contractor, prefix: true, allow_nil: true
  delegate :unregulated?, to: :tender, prefix: true
  delegate :tender_type_id, to: :tender

  accepts_nested_attributes_for :covers, allow_destroy: true
  accepts_nested_attributes_for :bidder_files, allow_destroy: true
  accepts_nested_attributes_for :offers, allow_destroy: true

  validates :contractor_id, presence: true
  validates :contractor_id, uniqueness: { scope: :tender_id, message: :non_uniq }
  validate :valid_sme_winner

  scope :by_offer_type, (lambda do |type|
    where("exists (select 'x' from offers where type_id = ? and offers.bidder_id=bidders.id)", type)
  end)
  scope :for_lot, (lambda do |lot|
    where("exists (select 'x' from offers where offers.bidder_id = bidders.id and offers.lot_id = ?)", lot)
  end)

  scope :for_pivot, (lambda do
    joins(:contractor)
      .joins('left join offers o on (bidders.id = o.bidder_id)')
      .joins('left join ownerships ow on contractors.ownership_id = ow.id')
      .select("distinct bidders.*, o.num,
               case o.num
                 when 0 then 'Основное'
                 when null then 'Нет'
                 else 'Альтернативное №' || o.num
               end as num_text,
               ow.shortname || ' ' || name as contractor_name")
      .order("contractor_name, num")
  end)

  scope :order_by_name, (lambda do
    joins(:contractor)
      .select("bidders.*, ow.shortname || ' ' || name as contractor_name")
      .joins('left join ownerships ow on ownership_id = ow.id')
      .order("contractor_name, bidders.id")
  end)

  scope :recieves, (lambda do |lot|
    where("exists (select 'x' from offers where offers.bidder_id = bidders.id and version = 0
      and offers.lot_id = ?
      and offers.status_id != ?
      and offers.type_id != ?)", lot, OfferStatuses::REJECT, OfferTypes::PICKUP)
  end)

  def build_offer(lot_id)
    lot = Lot.find(lot_id)
    offer = offers.build(lot: lot)
    offer.build_specifications(lot)
  end

  def next
    arr = tender.bidders.order_by_name.to_a
    arr[arr.find_index(self) + 1]
  end

  def previous
    arr = tender.bidders.order_by_name.to_a
    arr[arr.find_index(self) - 1]
  end

  def build_offers_from_tender
    tender.lots.each do |lot|
      o = offers.build(lot: lot, plan_lot_id: lot.plan_lot_id)

      lot.specifications.each do |spec|
        o.offer_specifications.build(specification: spec, plan_specification_id: spec.plan_specification_id, financing_id: spec.financing_id)
      end
    end
  end

  def non_sme?
    contractor_is_sme.nil? || (contractor_is_sme && contractor_sme_type_id.nil?)
  end

  def valid_sme_winner
    return unless regulated_win?
    errors.add(:contractor_id, :actual_sme) if non_sme?
  end

  def regulated_win?
    return unless tender
    offers.wins.present? && !tender_unregulated?
  end
end

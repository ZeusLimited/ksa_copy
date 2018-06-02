# frozen_string_literal: true

class UnfairContractor < ApplicationRecord
  has_paper_trail

  has_and_belongs_to_many :lots
  belongs_to :contractor

  validates :num, :date_in, :contractor_id, :contract_info, :unfair_info, presence: true

  delegate :fullname, :inn, :ogrn, :reg_date, :legal_addr, to: :contractor, prefix: true

  set_date_columns :date_in, :date_out if oracle_adapter?

  hex_fields :contractor_guid

  accepts_nested_attributes_for :lots, allow_destroy: true

  before_save :set_contractor_guid

  def lot_ids=(value)
    arr_lot_ids = value.kind_of?(String) ? value.split(",").map(&:to_i) : value
    super(arr_lot_ids)
  end

  COLUMNS = {
    c1: { type: :integer, style: :td_right, value: ->(r) { r['num'] }, width: 10 },
    c2: { type: :date, style: :td_date, value: ->(r) { r['date_in'].try(:to_date) }, width: 15 },
    c3: { type: :string, style: :td, value: ->(r) { r.contractor_fullname }, width: 50 },
    c4: { type: :string, style: :td, value: ->(r) { "ИНН: " + r.contractor_inn  + ", ОГРН: " + r.contractor_inn}, width: 30 },
    c5: { type: :date, style: :td_date, value: ->(r) { r.contractor_reg_date.try(:to_date) }, width: 15 },
    c6: { type: :string, style: :td, value: ->(r) { r.contractor_legal_addr }, width: 35 },
    c7: { type: :string, style: :td, value: ->(r) { r.lots.map{|a| "Закупка № #{a.fullnum} #{a.name} "}.join(",") }, width: 40 },
    c8: { type: :string, style: :td, value: ->(r) { r['contract_info'] }, width: 40 },
    c9: { type: :string, style: :td, value: ->(r) { r['unfair_info'] }, width: 40 },
    c10: { type: :date, style: :td_date, value: ->(r) { r['date_out'].try(:to_date) }, width: 15 },
    c11: { type: :string, style: :td, value: ->(r) { r['note'] }, width: 40 }
  }

  COLUMNS.each_pair do |ckey, cval|
    define_singleton_method(ckey) { |r| cval[:value].call(r) }
  end

  private

  def set_contractor_guid
    self.contractor_guid_hex = Contractor.find(contractor_id).guid_hex
  end

end

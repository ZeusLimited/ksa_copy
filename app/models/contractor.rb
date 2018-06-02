# frozen_string_literal: true

class Contractor < ApplicationRecord
  has_paper_trail
  include Constants
  include GuidGenerate

  set_date_columns :reg_date if oracle_adapter?

  enum status: { orig: 0, active: 1, old: 2, inactive: 3 }
  enum form: { businessman: 0, company: 1, foreign: 2, person: 3 }

  BUISNESS = proc { |c| c.company? || c.businessman? }

  has_many :plan_lot_contractors, dependent: :restrict_with_error
  has_many :bidders, dependent: :restrict_with_error
  has_many :sub_contractors, dependent: :restrict_with_error
  has_many :doc_takers, dependent: :restrict_with_error
  has_many :tender_requests, dependent: :restrict_with_error
  has_many :files, class_name: 'ContractorFile'

  belongs_to :user
  belongs_to :prev_contractor, class_name: "Contractor", foreign_key: "prev_id"
  belongs_to :next_contractor, class_name: "Contractor", foreign_key: "next_id"
  belongs_to :jsc_form, class_name: 'Dictionary', foreign_key: 'jsc_form_id'
  belongs_to :sme_type, class_name: 'Dictionary', foreign_key: 'sme_type_id'
  belongs_to :ownership, class_name: 'Ownership', foreign_key: 'ownership_id'
  belongs_to :parent, class_name: 'Contractor', foreign_key: 'parent_id'

  with_options unless: :user_b2b_integrator? do |pl|
    pl.validates :name, format: { without: /["«»']/, message: :with_quots }
    pl.validates :name, presence: true, length: { maximum: 500 }
    pl.validates :fullname, presence: true, length: { maximum: 500 }
    pl.validates :oktmo, presence: true, length: { maximum: 11 }, unless: :foreign?
    pl.validates :form, :status, presence: true
    pl.validates :user_id, presence: true
    pl.validates :sme_type_id, presence: true, if: proc { |c| c.is_sme? && c.user.can?(:contractor_boss, Contractor) },
                               unless: :user_b2b_integrator?

    pl.validates :inn, inn_format: true, unless: :foreign?
    pl.validates :kpp, kpp_format: true, if: :company?
    pl.validates :ogrn, ogrn_format: true, if: BUISNESS
    pl.validates :okpo, okpo_format: true, if: BUISNESS
    pl.validates :legal_addr, presence: true
    pl.validates :ownership_id, presence: true
  end

  validates :kpp, length: { maximum: 9 }

  with_options if: :view_for_main? do |c|
    c.validate :uniq_inn
  end

  with_options if: :view_for_all? do |c|
    c.validate :uniq_inn_kpp
  end

  accepts_nested_attributes_for :files, allow_destroy: true

  before_save :set_guid
  before_save :set_fields_to_nil, unless: :company?
  before_save :set_sme_type_to_nil, unless: :is_sme?
  after_create :ac_update_next_id, if: :prev?
  after_destroy :ad_null_next_id, if: :prev?

  STATUS_ORDER = [statuses[:active], statuses[:orig], statuses[:inactive], statuses[:old]]

  STATUS_ORDER_NUMS = [].tap do |mas|
    STATUS_ORDER.each_with_index { |o, i| mas << "WHEN #{o} THEN #{i}" }
  end.flatten.join(' ')

  DECODE_STATUS_ORDER = "CASE status #{STATUS_ORDER_NUMS} END"

  scope :by_inn, (lambda do |inn, kpp = nil|
    contractors = not_olds.where(inn: inn).order(DECODE_STATUS_ORDER).order(updated_at: :desc)
    contractors = contractors.where(kpp: kpp) unless Setting.contractor_form == 'main' || kpp.blank?
    contractors
  end)

  FULL_NAME =
    "case when u.id is not null then ' (Не добросовестный контрагент) ' else '' end" \
    " || coalesce(ow.shortname, '') || ' ' || contractors.name" \
    " || ', ИНН - ' || coalesce(contractors.inn, '')" \
    " || ', КПП - ' || coalesce(contractors.kpp, '')" \
    " || ', ОГРН - ' || coalesce(contractors.ogrn, '')" \
    " || case cast(contractors.is_sme as integer) when 1 then ', МСП' else '' end"
  NAME = "coalesce(ow.shortname,'') || ' ' || coalesce(contractors.name,'') || ', ИНН - ' || coalesce(contractors.inn,'')"
  scope :contractor_names, (lambda do |term|
    joins(sanitize_sql(["left join unfair_contractors u on u.contractor_guid = contractors.guid and coalesce(u.date_out, ?) >= ?", Date.current, Date.current]))
      .joins("left join ownerships ow on ow.id = contractors.ownership_id")
      .where("replace(lower(#{FULL_NAME}), 'ё', 'е') like replace(lower(?), 'ё', 'е')", "%#{term}%")
      .limit(15)
      .order(:name)
  end)
  scope :not_olds, -> { where(next_id: nil) }
  scope :sme, -> { where.not(is_sme: nil).where("coalesce(sme_type_id, is_sme) != 1") }

  delegate :name, to: :jsc_form, prefix: true, allow_nil: true
  delegate :name, to: :sme_type, prefix: true, allow_nil: true
  delegate :shortname, to: :ownership, prefix: true, allow_nil: true
  delegate :login, to: :user, prefix: true, allow_nil: true
  delegate :name_long, to: :parent, prefix: true, allow_nil: true

  hex_fields :guid

  def reestr_file?
    files.where(file_type_id: FileType::REESTR_MSP).exists?
  end

  def self.potential_bidders(terms = '')
    contractor_names(terms).not_olds.where(status: [statuses[:orig], statuses[:active]])
  end

  def self.bidders(terms, tender_type)
    result = contractor_names(terms).active.not_olds
    result = result.sme unless tender_type == TenderTypes::UNREGULATED
    result
  end

  def self.parent_contractors(terms, inn)
    contractor_names(terms).not_olds.where(inn: inn).order(DECODE_STATUS_ORDER)
  end

  def can_edit?(current_user)
    next_id.nil? && (orig? || current_user.can?(:change_status, Contractor))
  end

  def can_delete?(current_user)
    next_id.nil? && (orig? || current_user.can?(:change_status, Contractor))
  end

  def can_change_status?(current_user)
    next_id.nil? && current_user.can?(:change_status, Contractor)
  end

  def can_rename?(current_user)
    next_id.nil? && current_user.can?(:manage, :contractors_rename)
  end

  def name_long
    "#{ownership_shortname} #{name}, ИНН - #{inn}, КПП - #{kpp}, ОГРН - #{ogrn}" + (is_sme? ? ", МСП" : "")
  end

  def name_inn
    "#{ownership_shortname} #{name}, ИНН - #{inn}" + (is_sme? ? ", МСП" : "")
  end

  def name_short
    "#{ownership_shortname} #{name}"
  end

  def prev?
    prev_id.present?
  end

  def self.search(params)
    if params[:q].nil?
      Contractor.none
    else
      q_filter = "(replace(lower(contractors.name), 'ё', 'е') like replace(lower(?), 'ё', 'е'))
                  OR (replace(lower(contractors.fullname), 'ё', 'е') like replace(lower(?), 'ё', 'е'))
                  OR (contractors.inn = ?)
                  OR (contractors.ogrn = ?)"
      q = params[:q]
      rows = Contractor.not_olds
      rows = rows.where([q_filter, "%#{q}%", "%#{q}%", q, q]) if q.present?
      rows = rows.select("contractors.*, ow.shortname")
      rows = rows.joins("left join ownerships ow on ow.id = contractors.ownership_id")
      rows.order(:fullname)
    end
  end

  def unfair?(date = Date.current)
    @unfair_contractor_check ||= UnfairContractor.guid_eq(:contractor_guid, guid_hex).where("coalesce(date_out, ?) >= ?", date, date).exists?
  end

  def view_for_main?
    Setting.contractor_form == 'main'
  end

  def view_for_all?
    Setting.contractor_form == 'all'
  end

  def sme_in_plan?
    is_sme || is_sme.nil?
  end

  private

  def set_guid
    self.guid ||= guid_new
  end

  def set_fields_to_nil
    self.inn = nil if foreign?
    self.kpp = nil
    self.ogrn = nil unless businessman?
    self.okpo = nil unless businessman?
  end

  def set_sme_type_to_nil
    self.sme_type_id = nil
  end

  def ac_update_next_id
    Contractor.where(id: prev_id).update_all(next_id: id, status: Contractor.statuses[:old])
  end

  def ad_null_next_id
    Contractor.where(id: prev_id).update_all(next_id: nil, status: Contractor.statuses[:orig])
  end

  def uniq_inn
    return if foreign?
    rows = Contractor.not_olds
    rows = rows.where(inn: inn)
    rows = rows.guid_not_eq(:guid, guid_hex) if guid.present?

    errors.add(:inn, :uniq_inn) if rows.exists?
  end

  def uniq_inn_kpp
    return if foreign?
    rows = Contractor.not_olds
    rows = rows.where(inn: inn).where(kpp: kpp)
    rows = rows.guid_not_eq(:guid, guid_hex) if guid.present?

    errors.add(:base, :uniq_inn_kpp) if rows.exists?
  end

  def user_b2b_integrator?
    user_login == 'b2b_integrator'
  end
end

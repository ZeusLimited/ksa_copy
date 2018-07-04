# frozen_string_literal: true

class PlanLot < ApplicationRecord
  has_paper_trail version: :paper_trail_version

  include GuidGenerate
  include Constants
  include PlanLotsApi
  include TenderTypeConcern
  include Import
  if ActiveRecord::Base.connection.table_exists? 'settings'
    include "plan_lot_validation_#{Setting.get_all['company']}".classify.constantize
  end

  include Observers::PlanLotObserver
  include EtpAddressesConcern

  enum state: { unplan: 0, plan: 1 }

  attr_accessor :is_additional, :order1352_fullname, :include_ipivp

  before_create :lot_before_create
  before_save :set_default_values
  before_validation :set_root_customer

  belongs_to :commission
  belongs_to :department
  belongs_to :user
  belongs_to :protocol
  belongs_to :subject_type, class_name: "Dictionary", foreign_key: "subject_type_id"
  belongs_to :status, class_name: "Dictionary", foreign_key: "status_id"
  belongs_to :tender_type, class_name: "Dictionary", foreign_key: "tender_type_id"
  belongs_to :etp_address, class_name: "Dictionary", foreign_key: "etp_address_id"
  belongs_to :root_customer, class_name: "Department", foreign_key: "root_customer_id"
  belongs_to :sme_type, class_name: 'Dictionary', foreign_key: 'sme_type_id'
  belongs_to :order1352, class_name: 'Dictionary'
  belongs_to :direction, class_name: 'Direction', foreign_key: 'main_direction_id'
  belongs_to :regulation_item
  # belongs_to control_plan_lot
  has_one :eis,
          ->(pl) { where(year: pl.announce_date.year) },
          class_name: 'EisPlanLot',
          primary_key: 'guid',
          foreign_key: 'plan_lot_guid'
  has_one :control, class_name: 'ControlPlanLot', primary_key: 'guid', foreign_key: 'plan_lot_guid'
  # def control
  #   ControlPlanLot.guid_eq(:plan_lot_guid, guid_hex).take
  # end
  belongs_to :preselection, -> { where(version: 0) }, class_name: 'PlanLot',
                                                      primary_key: 'guid',
                                                      foreign_key: 'preselection_guid'

  has_many :plan_annual_limits, -> { order(:year) }, dependent: :destroy, inverse_of: :plan_lot
  has_many :plan_lot_contractors, dependent: :destroy, inverse_of: :plan_lot
  has_many :contractors, through: :plan_lot_contractors
  has_many :plan_specifications, -> { order(:num_spec) }, dependent: :destroy, inverse_of: :plan_lot
  has_many :plan_lots_files, dependent: :destroy
  has_many :lots
  has_many :tenders, through: :lots
  has_many :non_executions, -> { order(:created_at) }, class_name: 'PlanLotNonExecution',
                                                       primary_key: 'guid',
                                                       foreign_key: 'plan_lot_guid'
  has_one :actual_subscribe, foreign_key: 'plan_lot_guid', primary_key: 'guid'
  has_many :subscribes, foreign_key: 'plan_lot_guid', primary_key: 'guid'

  has_many :public_lots,
           -> { where(next_id: nil).order(:plan_lot_id) },
           class_name: 'Lot',
           foreign_key: 'plan_lot_guid',
           primary_key: 'guid'

  has_and_belongs_to_many :users, join_table: 'users_plan_lots'
  has_and_belongs_to_many :orders

  delegate :name, :level1_kk?, to: :commission, prefix: true, allow_nil: true
  delegate :name, :shortname, :fullname, to: :department, prefix: true, allow_nil: true
  delegate :name, to: :subject_type, prefix: true
  delegate :name, :stylename_html, :fullname, to: :status, prefix: true
  delegate :name, :fullname, to: :tender_type, prefix: true, allow_nil: true
  delegate :name, to: :etp_address, prefix: true, allow_nil: true
  delegate :name, to: :sme_type, prefix: true, allow_nil: true
  delegate :num, :date_confirm, to: :protocol, prefix: true, allow_nil: true
  delegate :fio_short, to: :user, prefix: true
  delegate :nmcd?, to: :plan_lots_files, prefix: true
  delegate :user_fio_short, to: :control, prefix: true, allow_nil: true
  delegate :created_at, to: :control, prefix: true, allow_nil: true
  delegate :ownership_shortname, :name, :fullname, :shortname, :eis223_limit, to: :root_customer, prefix: true, allow_nil: true
  delegate :fullname, to: :order1352, prefix: true, allow_nil: true
  delegate :title, :full_num, :announce_date, to: :preselection_plan_lot, prefix: true, allow_nil: true
  delegate :name, to: :direction, prefix: true, allow_nil: true
  delegate :num, to: :regulation_item, prefix: true, allow_nil: true

  set_date_columns :announce_date, :charge_date if oracle_adapter?

  hex_fields :guid, :additional_to, :preselection_guid

  scope :actuals, -> { where(version: 0) }
  scope :select_title_fields, -> { select("guid, num_tender, num_lot, lot_name, gkpz_year") }
  scope :regulated, -> { where.not(tender_type_id: TenderTypes::UNREGULATED) }
  scope :unregulated, -> { where(tender_type_id: Constants::TenderTypes::UNREGULATED) }
  scope :not_only_source, -> { where.not(tender_type_id: TenderTypes::ONLY_SOURCE) }

  scope :by_num_or_name, (lambda do |q|
    where(["(num_tender || '.' || num_lot LIKE ? OR lower(lot_name) LIKE lower(?))", "#{q}%", "%#{q}%"])
  end)

  scope :by_status, ->(status) { where(status_id: status) }
  scope :by_root_customer, ->(root_cust_id) { where(root_customer_id: root_cust_id) }
  scope :all_versions, ->(hex) { guid_eq("plan_lots.guid", hex).order(:version) }
  scope :in_control, -> { joins('inner join control_plan_lots on control_plan_lots.plan_lot_guid = plan_lots.guid') }
  scope :out_control, -> { where('plan_lots.guid not in (select plan_lot_guid from control_plan_lots)') }

  scope :on_date, (lambda do |dbegin, dend|
    sql = <<-SQL
      inner join protocols p on (plan_lots.protocol_id = p.id)
      inner join (
        select l.guid, max(p1.date_confirm) as date_confirm
        from plan_lots l
        inner join protocols p1 on (p1.id = l.protocol_id and l.protocol_id is not null)
        where p1.date_confirm between ? and ?
        Group By l.guid) vi on (vi.guid = plan_lots.guid and p.date_confirm = vi.date_confirm)
    SQL

    joins sanitize_sql([sql, dbegin, dend])
  end)

  scope :last_confirm_versions_in_tender, (lambda do |gkpz_year, root_customer_id, num_tender|
    on_date(Date.new(2007), Date.current)
      .by_root_customer(root_customer_id)
      .where(gkpz_year: gkpz_year)
      .where(num_tender: num_tender)
  end)

  scope :plan_tenders, -> { select(:gkpz_year, :root_customer_id, :num_tender).distinct }

  scope :by_spec_field_in, (lambda do |where_clause|
    where(id: PlanSpecification.where(where_clause).select(:plan_lot_id))
  end)

  scope :user_scope, (lambda do |user|
    user&.root_dept_id ? by_spec_field_in(customer_id: Department.subtree_ids_for(user.root_dept_id)) : all
  end)

  scope :history, (lambda do |guid|
    guid_eq(:guid, guid)
      .includes(:plan_annual_limits, :plan_specifications, :order1352, :direction, :commission, :department,
                :etp_address, :tender_type, :subject_type, :status, :protocol, :user, :regulation_item,
                plan_lot_contractors: :contractor)
      .order(:version)
  end)

  scope :edit_list_by_root_customer, (lambda do |root_cust|
    by_root_customer(root_cust).where(status_id: PlanLotStatus::EDIT_LIST)
  end)

  scope :declared, -> { where(guid: Lot.select(:plan_lot_guid).where.not(plan_lot_guid: nil)) }
  scope :undeclared, -> { where.not(guid: Lot.select(:plan_lot_guid).where.not(plan_lot_guid: nil)) }

  scope :by_name_words, ->(name_words) { where(filter_by_search_name(name_words)) }
  scope :by_numbers, ->(numbers) { where(filter_by_search_num(numbers)) }
  scope :by_num, ->(num) { where("(num_tender || '.' || num_lot like ?)", "#{num}%") }

  GKPZ_STATE = { "Текущая" => "current", "На период" => "on_date" }.freeze

  scope :without_bidders, -> { where.not(id: PlanLotContractor.all.select(:plan_lot_id)) }
  scope :invalid_okved, (lambda do
    sql = <<-SQL
    exists
      (select 'x'
       from plan_specifications ps
         inner join okved on okved.id = ps.okved_id
         inner join okdp on okdp.id = ps.okdp_id
       Where
         plan_lots.id = ps.plan_lot_id
         and (
         okdp.ref_type != case when extract (year from plan_lots.announce_date) >= 2016 then 'OKPD2' else 'OKDP' end
         or
         okved.ref_type != case when extract (year from plan_lots.announce_date) >= 2016 then 'OKVED2' else 'OKVED' end
        )
      )
    SQL
    where(sql)
  end)

  accepts_nested_attributes_for :plan_specifications, allow_destroy: true
  accepts_nested_attributes_for :plan_lots_files, allow_destroy: true
  accepts_nested_attributes_for :plan_lot_contractors, allow_destroy: true
  accepts_nested_attributes_for :plan_annual_limits, allow_destroy: true

  with_options if: proc { |pl| pl.include_ipivp.nil? } do |pl|
    pl.validates :commission_id, absence: true, if: :noncompetitive?
    pl.validates :commission_id, presence: true, unless: :noncompetitive?
    pl.validates :department_id, presence: true
    pl.validates :tender_type_id, :etp_address_id, :regulation_item_id, presence: true

    pl.validate :valid_potential_contractors

    pl.validate :restrict_not_level1kk
    def restrict_not_level1kk
      return if different_organizer? || noncompetitive?
      errors.add(:commission_id, :restrict_not_level1kk) unless commission_level1_kk?
    end
  end

  validates :num_tender, :num_lot, :gkpz_year, numericality: { only_integer: true }, presence: true
  validates :lot_name, :announce_date, :subject_type_id, presence: true
  validates :additional_to_hex, :additional_num, presence: true, if: proc { |pl| pl.is_additional == '1' }
  validates :order1352_id, presence: true, if: :public_eis?
  validates :order1352_id, :sme_type_id, absence: true, unless: :public_eis?
  # validates :tender_type_id, exclusion: { in: TenderTypes::BANNED }

  validates_associated :plan_specifications, :plan_lot_contractors
  validates_associated :plan_annual_limits, if: :preselection?

  validates :explanations_doc, :tender_type_explanations, presence: true, if: :only_source?
  validate :validate_announce_date, :valid_szk, :validate_okdp_etp, :valid_uniq_num_lot
  validate :valid_additional, :valid_sme_order1352
  validate :valid_single_source_contractors_size
  validate :valid_annual_limits
  validate :valid_announce_date, if: :preselection_guid
  validate :valid_etp_address
  validate :valid_regulation_item
  def valid_regulation_item
    return unless tender_type_id && regulation_item_id
    return if RegulationItem.for_type(tender_type_id).pluck(:id).include?(regulation_item_id)
    errors.add(:regulation_item_id, :non_valid)
  end

  validates :lot_name, length: { maximum: 500 }
  validates :explanations_doc, length: { maximum: 1000 }
  validates :tender_type_explanations, length: { maximum: 1000 }

  validate :valid_different_organizer, if: :noncompetitive?
  def valid_different_organizer
    errors.add(:department_id, :different_organizer) if different_organizer?
  end

  def different_organizer?
    return unless department
    department.root_id != first_spec_root_customer
  end

  def self.invalid_sme
    where(sme_type_id: SmeTypes::SME)
      .where(id: joins(plan_lot_contractors: :contractor).where(contractors: { is_sme: false }).select(:id))
  end

  def not_deleted_version?
    PlanLotStatus::NOT_DELETED_LIST.include?(status_id)
  end

  def last_agree_version
    @last_agree_version ||= all_versions.by_status(PlanLotStatus::AGREEMENT_LIST).first
  end

  def last_protocol_version
    @last_protocol_version ||= protocol_versions.first
  end

  def search_tenders_params
    { tender_filter: { years: [gkpz_year], customers: [root_customer_id], search_by_gkpz_num: full_num } }
  end

  def can_edit_state?(current_user)
    current_user.can?(:edit_state, PlanLot) || present_at_sd?
  end

  def tenders_info
    tenders.select "tenders.id, lots.id as lot_id, tenders.num, lots.num as num_lot, tenders.announce_date"
  end

  def additional_plan_lot
    PlanLot.all_versions(additional_to_hex).first
  end

  def preselection_plan_lot
    PlanLot.all_versions(preselection_guid_hex).first
  end

  def contract?
    l = PlanLot.last_public_lot(guid_hex)
    l ? l.any_existing_contract? : false
  end

  def title
    "#{num_tender}.#{num_lot} #{lot_name}"
  end

  def valid_additional
    return unless additional_to
    l = PlanLot.last_public_lot(additional_to_hex)
    if l
      errors.add(:additional_to_hex, :contract) unless l.any_existing_contract?
    else
      errors.add(:additional_to_hex, :lot_not_public)
    end
    errors.add(:additional_to_hex, :customer) if first_spec_root_customer != additional_plan_lot.root_customer_id
  end

  def valid_uniq_num_lot
    return unless num_lot && num_tender && gkpz_year && !plan_specifications.empty?

    customer_id = plan_specifications.first.customer.root_id

    return unless customer_id

    plan_lots = PlanLot.actuals
                       .where(gkpz_year: gkpz_year)
                       .where(root_customer_id: customer_id)
                       .where(num_tender: num_tender)
                       .where(num_lot: num_lot)
    plan_lots = plan_lots.guid_not_eq(:guid, guid_hex) if guid
    errors.add(:num_lot, "у этой закупки уже есть такой лот!") if plan_lots.count > 0
  end

  def valid_potential_contractors
    contractor_ids = plan_lot_contractors.map(&:contractor_id).compact
    errors.add(:base, :zero_contractors) if preselection_guid.present? && !contractor_ids.empty?
    if contractor_ids.size < minimum_contractors
      errors.add(:base, minimum_contractors == 1 ? :less_then_minimum_contractors_ei : :less_then_minimum_contractors)
    end
    errors.add(:base, :not_uniq_contractors) if contractor_ids.uniq.size != contractor_ids.size
  end

  def valid_single_source_contractors_size
    return unless only_source? || single_source?
    contractor_ids = plan_lot_contractors.map(&:contractor_id).compact
    errors.add(:base, :must_have_one_contractor) if contractor_ids.size != minimum_contractors
  end

  def valid_annual_limits
    errors.add(:base, :must_have_limits) if preselection? && plan_annual_limits.empty?
    errors.add(:base, :must_have_no_limits) unless preselection? || plan_annual_limits.empty?
  end

  def minimum_contractors
    preselection_guid.blank? ? render_minimum_contractors : 0
  end

  def render_minimum_contractors
    ei? ? 1 : 3
  end

  def validate_okdp_etp
    return if tender_type_id && Constants::TenderTypes::ORDER616_EXCLUSION.include?(tender_type_id)
    incorrect = plan_specifications.any? do |ps|
      [ps.okdp_id, etp_address_id].all? && !etp? &&
        OkdpSmeEtp.exists?(code: ps.okdp_code, okdp_type: Constants::OkdpSmeEtpType::ETP)
    end
    errors.add(:etp_address_id, :order616) if incorrect
  end

  def validate_announce_date
    incorrect = plan_specifications.any? do |ps|
      [announce_date, ps.delivery_date_begin].all? && announce_date > ps.delivery_date_begin
    end
    errors.add(:announce_date, "не может быть позже даты начала поставки") if incorrect
  end

  def valid_szk
    return if unregulated? || only_source? || department_id.nil? || commission.nil?
    incorrect = plan_specifications.any? do |ps|
      department.root_id != ps.customer.root_id
    end && !commission.for_customers?
    errors.add(:commission_id, "должна быть «СЗК», т.к. заказчик не является организатором") if incorrect
  end

  def max_protocol_date_confirm
    PlanLot.joins(:protocol).all_versions(guid_hex).maximum("date_confirm")
  end

  def session_params
    {
      department_id: department_id,
      announce_date: announce_date,
      subject_type_id: subject_type_id,
      tender_type_id: tender_type_id,
      regulation_item_id: regulation_item_id,
      commission_id: commission_id,
      etp_address_id: etp_address_id,
      gkpz_year: gkpz_year,
    }
  end

  def all_cost
    plan_specifications.sum('cost * qty')
  end

  def cost
    plan_specifications.map { |ps| ps.total_cost unless ps._destroy }.sum
  end

  def cost_nds
    plan_specifications.map { |ps| ps.total_cost_nds unless ps._destroy }.sum
  end

  def public_eis?
    !unregulated?
  end

  def full_num
    [num_tender, num_lot].compact.join('.')
  end

  def directions
    plan_specifications(&:direction_name).uniq.join(', ')
  end

  def all_versions
    PlanLot.all_versions(guid_hex)
  end

  def protocol_versions
    all_versions.where.not(protocol_id: nil)
  end

  def nmcd_file
    return if plan_lots_files.any?(&:nmcd?)
    errors.add(:plan_lots_files, :nmcd)
  end

  def self.all_spec_hexs(hex)
    guid_eq("plan_lots.guid", hex)
      .joins(:plan_specifications)
      .select("plan_specifications.guid")
      .distinct
      .map(&:guid_hex)
  end

  def self.build_plan_lot(current_user, params, session)
    if params[:clone].present?
      pl = PlanLot.find(params[:clone]).clone_new_version(current_user, Constants::PlanLotStatus::NEW)
      pl.plan_specifications.each { |ps| ps.guid = nil }
    elsif session[:plan_new]
      pl = PlanLot.new(session[:plan_new])
      pl.plan_specifications.build(session[:specification_new])
    else
      pl = PlanLot.new
      pl.plan_specifications.build
    end

    pl.plan_specifications.each do |ps|
      ps.qty ||= 1
      ps.unit_id ||= Unit.find_by(code: Constants::Units::DEFAULT_UNIT).id
    end

    pl.gkpz_year = actual_gkpz_year_for_new unless params[:clone].present?
    if params[:additional].present?
      pl.is_additional = true
      pl.additional_to_hex = params[:additional]
    end
    pl
  end

  def self.actual_gkpz_year_for_new
    Time.current.month > 7 ? Time.current.year + 1 : Time.current.year
  end

  def self.build_plan_lot_with_params(current_user, params, plan_lot_old)
    pl = PlanLot.new(params)
    pl.guid = plan_lot_old.guid
    pl.gkpz_year = plan_lot_old.gkpz_year
    pl.user = current_user
    pl.status_id = Constants::PlanLotStatus::NEW
    pl
  end

  def self.preselection_search(term, cust_id)
    PlanLot
      .actuals
      .where(tender_type_id: [TenderTypes::PO, TenderTypes::ORK])
      .by_root_customer(Department.find(cust_id).root_id)
      .by_num_or_name(term)
      .where.not(status_id: PlanLotStatus::IMPORT)
      .order(:num_tender)
  end

  def self.search_edit_list(term, cust_id)
    PlanLot.actuals
           .by_num_or_name(term)
           .order('gkpz_year DESC')
           .edit_list_by_root_customer(Department.find(cust_id).root_id)
  end

  def self.search_all(term, cust_id, gkpz_years)
    plan_lots = PlanLot.actuals
                       .by_num_or_name(term)
                       .order('gkpz_year DESC')
    unless cust_id.blank?
      root_ids = Department.where(id: cust_id).map(&:root_id)
      plan_lots = plan_lots.by_root_customer(root_ids)
    end
    plan_lots = plan_lots.where(gkpz_year: gkpz_years) unless gkpz_years.blank?
    plan_lots
  end

  def self.additional_search(term, cust_id)
    root_cust_id = Department.find(cust_id.to_i).root_id
    PlanLot.last_agreement.by_root_customer(root_cust_id).by_num_or_name(term)
  end

  def clone_new_version(current_user, status_id, state = nil)
    fail CanCan::AccessDenied, 'Нельзя клонировать лот отсутствующий в базе!' unless persisted?

    new_lot = deep_clone(
      include: [{ plan_specifications: [:fias_plan_specifications, :plan_spec_amounts] }, :plan_lot_contractors],
      validate: false
    )
    plan_lots_files.each do |file|
      new_lot.plan_lots_files << file.deep_clone if file.tender_file_user_id == current_user.id
    end
    new_lot.user = current_user
    new_lot.protocol_id = nil
    new_lot.version = 0
    new_lot.status_id = status_id
    new_lot.state = state if state
    new_lot
  end

  def self.max_num_tender(gkpz_year, root_customer)
    max_num = actuals
              .where(gkpz_year: gkpz_year)
              .where(root_customer_id: root_customer.id)
              .maximum(:num_tender)
    max_num ? max_num + 1 : 1
  end

  def can_delete?
    Constants::PlanLotStatus::DELETED_LIST.include?(status_id) &&
      all_versions.where(status_id: Constants::PlanLotStatus::NOT_DELETED_LIST).count.zero?
  end

  def can_edit?
    Constants::PlanLotStatus::EDIT_LIST.include?(status_id)
  end

  def self.filter_by_search_name(search)
    words = search.strip.split(/[\s,]+/)
    filters = []
    words.each do |w|
      filters << sanitize_sql(
        ["(replace(lower(plan_lots.lot_name), 'ё', 'е') like replace(lower('%s'), 'ё', 'е'))", "%#{w}%"],
      )
    end
    filters.join(' OR ')
  end

  def self.filter_by_search_num(search)
    words = search.strip.split(/[\s,]+/)
    filters = []
    words.each do |w|
      if w[-1] == "+"
        filters << sanitize_sql(
          ["(preselections_plan_lots.num_tender || '.' || preselections_plan_lots.num_lot like '%s')", "#{w.chop!}%"],
        )
      end
      filters << sanitize_sql(["(plan_lots.num_tender || '.' || plan_lots.num_lot like '%s')", "#{w}%"])
    end
    filters.join(' OR ')
  end

  def self.reindex_versions(lot_guid_hexdigest)
    PlanLot.all_versions(lot_guid_hexdigest).each_with_index { |l, i| l.update_attribute(:version, i) }
  end

  def self.delete_current_version(lot_guid_hexdigest)
    current_version(lot_guid_hexdigest).destroy
    reindex_versions(lot_guid_hexdigest)
  end

  def delete_version
    destroy
    PlanLot.reindex_versions(guid_hex)
  end

  def self.current_version(lot_guid_hexdigest)
    PlanLot.all_versions(lot_guid_hexdigest).first
  end

  def execute?
    Lot.where(plan_lot_id: id).count > 0
  end

  def declared?
    @declared_to_b ||= public_lots.present?
  end

  def update_bind_execute
    lots.each do |lot|
      lot.name = lot_name
      lot.root_customer_id = root_customer_id
      lot.subject_type_id = subject_type_id
      lot.main_direction_id = main_direction_id
      lot.save(validate: false)
    end

    plan_specifications.each do |ps|
      ps.specifications.each do |spec|
        spec.direction_id = ps.direction_id
        spec.unit_id = ps.unit_id
        spec.product_type_id = ps.product_type_id
        spec.customer_id = ps.customer_id
        spec.consumer_id = ps.consumer_id
        spec.invest_project_id = ps.invest_project_id
        spec.save(validate: false)
      end
    end
  end

  def to_lot(num, nested = true)
    l = Lot.new
    l.gkpz_year = gkpz_year
    l.name = lot_name
    l.num = num
    l.plan_lot_id = id
    l.plan_lot_guid = guid
    l.status_id = Constants::LotStatus::NEW
    l.subject_type_id = subject_type_id

    return l unless nested

    plan_specifications.each { |ps| l.specifications << ps.to_specification }
    l
  end

  def add_plan_specifications(ps)
    if ps
      ps.each do |item|
        num_spec = plan_specifications.last.num_spec + 1
        plan_spec = PlanSpecification.find(item.to_i)
        plan_specifications.build(
          plan_spec.attributes.merge(num_spec: num_spec, plan_lot_id: id, guid: nil)
        )
      end
    end
  end

  def can_add_spec?(current_user)
    current_user.can?(:update, PlanLot)
  end

  def already_sd?
    Protocol.by_year_and_cust_and_ctype(gkpz_year, first_spec_root_customer, CommissionType::SD).exists?
  end

  def present_at_sd?
    PlanLot.all_versions(guid_hex).where(status: PlanLotStatus::CONFIRM_SD).exists?
  end

  def actualize_state
    self.state = already_sd? ? 'unplan' : 'plan'
  end

  def in_unplan?(date = Date.current)
    unplan? && !Protocol.joins(:commission)
                        .where(id: PlanLot.all_versions(guid_hex).pluck(:protocol_id))
                        .where(commissions: { commission_type_id:  CommissionType::SD })
                        .where("date_confirm <= ?", date)
                        .exists?
  end

  def can_execute?
    return false if lots.exists?
    Lot
      .joins(:plan_lot)
      .where.not(status_id: LotStatus::FATAL)
      .where.not(id: Contract.joins(:contract_termination).select(:lot_id))
      .guid_eq("plan_lots.guid", guid_hex)
      .count.zero?
  end

  def customer_is_organizer?
    root_customer.id == department.root_id
  end

  def all_orders
    Order
      .joins(:plan_lots)
      .guid_eq("plan_lots.guid", guid_hex)
  end

  def last_valid_order
    Order
      .joins(:plan_lots)
      .guid_eq("plan_lots.guid", guid_hex)
      .order(:receiving_date)
      .last
  end

  def confirmed_order?
    return false unless last_valid_order
    !last_valid_order.agreement_date.nil?
  end

  def all_public_lots
    Lot
      .joins(:plan_lot)
      .guid_eq('plan_lots.guid', guid_hex)
      .order('plan_lots.version')
      .pluck(:id)
  end

  def order_not_published?
    return false unless last_valid_order
    !last_valid_order.lots.where(id: all_public_lots).exists?
  end

  def can_execute_from_preselection?
    return true unless preselection_guid
    Lot
      .joins(:plan_lot)
      .guid_eq("plan_lots.guid", preselection_guid_hex)
      .where(status_id: LotStatus::HELD)
      .count != 0
  end

  def to_struct
    to_json(except: [:guid, :preselection_guid, :additional_to],
            methods: [:guid_hex, :preselection_guid_hex, :additional_to_hex],
            include: [:plan_lot_contractors,
                      :protocol,
                      plan_specifications: { except: :guid, include: :plan_spec_amounts }])
  end

  def self.last_public_lot(plan_lot_guid_hex)
    Lot
      .where(next_id: nil)
      .joins(:plan_lot)
      .guid_eq(:plan_lot_guid, plan_lot_guid_hex)
      .order('plan_lots.version')
      .first
  end

  def last_public_lot
    public_lots.sort_by(&:plan_lot_id).last
  end

  def exclusion_order1352?
    Order1352::EXCLUSIONS.include?(order1352_id)
  end

  private

  def cost_nds_greater_then_eis223_limit?
    cost_nds > root_customer_eis223_limit
  end

  def okdp_in_sme?
    okdp_ids = plan_specifications.map(&:okdp_id)
    Okdp.where(id: okdp_ids).any? do |okdp|
      OkdpSmeEtp.exists?(code: okdp.path.map(&:code), okdp_type: Constants::OkdpSmeEtpType::SME)
    end
  end

  def valid_announce_date
    return unless announce_date && preselection_plan_lot_announce_date
    errors.add(:announce_date, :after_preselect) if announce_date <= preselection_plan_lot_announce_date + 25.days
  end

  def valid_sme_order1352
    return unless order1352_id && sme_type_id && order1352_id != Order1352::SELECT
    errors.add(:sme_type_id, :non_sme)
  end

  def valid_etp_address
    errors.add(:etp_address_id, :not_etp) if tender_type_non_etp? && etp_address_id != EtpAddress::NOT_ETP
    errors.add(:etp_address_id, :etp) if tender_type_etp? && etp_address_id == EtpAddress::NOT_ETP
  end

  def first_spec_root_customer
    spec = plan_specifications.first
    spec && spec.customer_id ? spec.customer.root_id : root_customer_id
  end

  def main_direction
    return if plan_specifications.empty?
    plan_specifications
      .group_by(&:direction_id)
      .each_with_object({}) { |(k, v), h| h[k] = v.sum(&:total_cost) }
      .sort_by { |e| [-e[1], Direction.priorities[e[0]]] }
      .first[0]
  end

  def set_root_customer
    self.root_customer_id = first_spec_root_customer if first_spec_root_customer
  end

  def lot_before_create
    self.status_id ||= Constants::PlanLotStatus::NEW
    self.version ||= 0
    all_versions.update_all('version = version + 1') if guid
    self.guid ||= guid_new
  end

  def set_default_values
    if is_additional != '1'
      self.additional_to = nil
      self.additional_num = nil
    end
    self.preselection_guid = nil unless TenderTypes::FOR_PO.include?(tender_type_id)
    self.main_direction_id = main_direction if first_spec_root_customer
  end
end

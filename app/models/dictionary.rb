# frozen_string_literal: true

class Dictionary < ApplicationRecord
  include Constants
  has_paper_trail

  has_and_belongs_to_many :fact_types,
                          join_table: 'tender_type_rules',
                          class_name: 'Dictionary',
                          foreign_key: 'plan_type_id',
                          association_foreign_key: 'fact_type_id'

  has_and_belongs_to_many :regulation_items

  scope :tender_types, -> { where(ref_type: 'Tender_Types').order(:position) }
  scope :with_rules, -> { joins(:fact_types) }
  scope :financing_sources, -> { where(ref_type: 'Financing_Sources').order(:position) }
  scope :financing_sources_invest, -> { financing_sources.where(ref_id: Financing::GROUP2) }
  scope :commission_types, -> { where(ref_type: 'Commission_Types').order(:position) }
  scope :commissioners, -> { where(ref_type: 'Commissioner').order(:position) }
  scope :subject_types, -> { where(ref_type: 'Subject_Types').order(:position) }
  scope :product_types, -> { where(ref_type: 'Product_Types').order(:position) }
  scope :etp_addresses, -> { where(ref_type: 'Etp_Addresses').order(:position) }
  scope :etp_addresses_without, -> (etp_address) { etp_addresses.where.not(ref_id: etp_address) }
  scope :plan_lot_statuses, -> { where(ref_type: 'PlanLotStatus').order(:position) }
  scope :lot_statuses, -> { where(ref_type: 'Lot_Status').order(:position) }
  scope :format_meetings, -> { where(ref_type: 'Format_Meeting').order(:position) }
  scope :plan_lot_filetypes, -> { where(ref_type: 'PlanLotFileType').order(:position) }
  scope :tender_file_types, -> { where(ref_type: 'TenderFileType').order(:position) }
  scope :nds_values, -> { where(ref_type: 'NDS').order(:position) }
  scope :cost_docs, -> { where(ref_type: 'CostDoc').order(:position) }
  scope :invest_project_types, -> { where(ref_type: 'InvestProjectType').order(:position) }
  scope :cover_labels, -> { where(ref_type: 'Cover_Labels').order(:position) }
  scope :offer_filetypes, -> { where(ref_type: 'OfferFileType').order(:position) }
  scope :destinations, -> { where(ref_type: 'Destinations').order(:position) }
  scope :content_offer_types, -> { where(ref_type: 'ContentOfferType').order(:position) }
  scope :offer_statuses, -> { where(ref_type: 'OfferStatus').order(:position) }
  scope :offer_statuses_u, -> { where(ref_type: 'OfferStatus').order(:position).where.not(ref_id: OfferStatuses::NEW) }
  scope :contract_termination_types, -> { where(ref_type: 'ContractTerminationTypes').order(:position) }
  scope :privacy, -> { where(ref_type: 'Privacy').order(:position) }
  scope :activities, -> { where(ref_type: 'Activities').order(:position) }
  scope :object_stages, -> { where(ref_type: 'Object_Stages').order(:position) }
  scope :buisness_types, -> { where(ref_type: 'Buisness_Types').order(:position) }
  scope :sme_types, -> { where(ref_type: 'Sme_Types').order(:position) }
  scope :contractor_sme_types, -> { where(ref_type: 'Contractor_Sme_Types').order(:position) }
  scope :contract_types, -> { where(ref_type: 'Contract_Types').order(:position) }
  scope :jsc_forms, -> { where(ref_type: 'JSC_Form').order(:position) }
  scope :winner_protocol_solution_types, -> { where(ref_type: 'WinnerProtocolSolutionTypes').order(:position) }
  scope :wp_solution_types_without_single_source, -> { winner_protocol_solution_types.where.not(ref_id: WinnerProtocolSolutionTypes::SINGLE_SOURCE) }
  scope :order1352, -> { where(ref_type: 'Order1352').order(:position) }
  scope :order1352_without_not_select, -> { where(ref_type: 'Order1352').where.not(ref_id: Order1352::NOT_SELECT).order(:position) }
  scope :subscribe_actions, -> { where(ref_type: 'SubscribeActions').order(:position) }
  scope :subscribe_warnings, -> { where(ref_type: 'SubscribeWarnings').order(:position) }
  scope :contractor_file_types, -> { where(ref_type: 'ContractorFileTypes').order(:position) }

  def self.order1352_special(reg_item)
    joins(:regulation_items).where(regulation_items: { id: reg_item }).presence || order1352_without_not_select
  end

  scope :by_name, ->(text) { where('lower(name) = lower(?)', text) }

  has_one :declension, as: :content

  def color
    return unless stylename_html && stylename_html =~ /background-color: #/
    stylename_html.match(/background-color: (.*);/)[1]
  end

  def self.types_for_public(source_types)
    types = source_types.map { |type| Dictionary.with_rules.where(ref_id: type).pluck(:fact_type_id).push(type) }
    result = types.shift
    types.each { |type| result &= type }
    Dictionary.where(ref_id: result)
  end

  def self.etp_for_public(source_etps)
    if source_etps.size == 1 && source_etps[0] == EtpAddress::NOT_ETP
      Dictionary.etp_addresses
    else
      Dictionary.etp_addresses.where('ref_id != ?', EtpAddress::NOT_ETP)
    end
  end

  attr_writer :color

  def self.next_ref_id(ref_type)
    Dictionary.where(ref_type: ref_type).maximum(:ref_id) + 1
  end

  def generate_ref_id
    self.ref_id = Dictionary.next_ref_id(ref_type)
  end

  def self.search(params)
    dics = order(:position)
    dics = dics.where(ref_type: params[:ref_type]) if params[:ref_type].present?
    dics
  end

  def self.collection_for_select
    select(:name, :ref_id, :fullname).map { |t| [t.name, t.id, { 'title' => t.fullname }] }
  end

  def name_i
    fullname
  end
end

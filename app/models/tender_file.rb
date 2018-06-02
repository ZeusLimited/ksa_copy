# frozen_string_literal: true

class TenderFile < ApplicationRecord
  include Constants::TenderFileArea
  mount_uploader :document, TenderFileUploader

  belongs_to :user
  has_many :plan_lots_files, dependent: :destroy
  has_many :link_tender_files, dependent: :destroy
  has_many :bidder_files, dependent: :destroy
  has_many :contract_files, dependent: :destroy
  has_many :protocol_files, dependent: :destroy
  has_many :contractor_files, dependent: :destroy
  has_many :order_files, dependent: :destroy

  before_save :update_file_attributes

  scope :plan, -> { where(tender_files: { area_id: PLAN_LOT }) }
  scope :tenders, -> { where(area_id: TENDER) }
  scope :bidders, -> { where(area_id: BIDDER) }
  scope :protocols, -> { where(area_id: PROTOCOL) }
  scope :contracts, -> { where(area_id: CONTRACT) }
  scope :contractors, -> { where(area_id: CONTRACTOR) }
  scope :orders, -> { where(area_id: ORDER) }

  scope :unused_plan, -> { plan.where.not(id: PlanLotsFile.select(:tender_file_id)) }
  scope :unused_tenders, -> { tenders.where.not(id: LinkTenderFile.select(:tender_file_id)) }
  scope :unused_bidders, -> { bidders.where.not(id: BidderFile.select(:tender_file_id)) }
  scope :unused_protocols, -> { protocols.where.not(id: ProtocolFile.select(:tender_file_id)) }
  scope :unused_contracts, -> { contracts.where.not(id: ContractFile.select(:tender_file_id)) }
  scope :unused_contractors, -> { contractors.where.not(id: ContractorFile.select(:tender_file_id)) }
  scope :unused_orders, -> { orders.where.not(id: OrderFile.select(:tender_file_id)) }

  def filename
    read_attribute(:document)
  end

  def valid_url
    document.valid_url
  end

  validates :document, :area_id, :year, presence: true

  private

  def update_file_attributes
    return unless document.present? || document_changed?
    self.content_type = document.file.content_type
    self.file_size = document.file.size
  end
end

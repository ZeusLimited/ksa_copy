# frozen_string_literal: true

class Commission < ApplicationRecord
  include Constants
  has_paper_trail

  belongs_to :department
  belongs_to :commission_type, class_name: "Dictionary", foreign_key: "commission_type_id"

  has_many :protocols, dependent: :restrict_with_error
  has_many :plan_lots, dependent: :restrict_with_error
  has_many :tenders, dependent: :restrict_with_error
  has_many :open_protocols, dependent: :restrict_with_error
  has_many :rebid_protocols, dependent: :restrict_with_error
  has_many :commission_users, dependent: :destroy
  has_one :declension, as: :content
  accepts_nested_attributes_for :commission_users, allow_destroy: true

  scope :actuals, -> { where(is_actual: true) }
  scope :execute_group, -> { where(commission_type_id: CommissionType::EXECUTE_GROUP) }
  scope :czk, -> { where(commission_type_id: CommissionType::CZK) }
  scope :confirm_group, (lambda do |dep_id|
    where.not(commission_type_id: [CommissionType::SD]).where(department_id: dep_id)
  end)
  scope :confirm_group_sd, (lambda do |dep_id|
    where(commission_type_id: [CommissionType::SD]).where(department_id: dep_id)
  end)
  scope :select_for_department, (lambda do |dep_id|
    actuals
    .execute_group
    .joins(:commission_type)
    .select("commissions.id as id, dictionaries.name || ' - ' || commissions.name as name")
    .where(department_id: dep_id)
  end)

  validates :name, length: { maximum: 255 }

  def czk?
    commission_type_id == CommissionType::CZK
  end

  def sd?
    commission_type_id == CommissionType::SD
  end

  def szk?
    commission_type_id == CommissionType::SZK
  end

  def level1_kk?
    commission_type_id == CommissionType::LEVEL1_KK
  end

  def for_customers?
    for_customers || szk?
  end

  def self.for_organizer(org_id)
    org_id = org_id.to_i
    root_org_id = Department.find(org_id).root_id
    commissions = select_for_department(org_id)
    commissions += select_for_department(root_org_id).czk if org_id != root_org_id
    commissions
  end

  def commission_type_name
    "#{commission_type.name} - #{name}"
  end

  def name_i
    try(:name)
  end

  def name_r
    declension.try(:name_r) || name
  end

  def name_d
    declension.try(:name_d) || name
  end
end

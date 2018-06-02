# frozen_string_literal: true

class RegulationItem < ApplicationRecord
  has_paper_trail

  has_and_belongs_to_many :tender_types,
                          -> { order(:position) },
                          join_table: 'reg_item_tender_types',
                          class_name: 'Dictionary',
                          foreign_key: 'item_id',
                          association_foreign_key: 'tender_type_id'

  has_many :plan_lots, dependent: :restrict_with_error

  has_and_belongs_to_many :departments
  has_and_belongs_to_many :dictionaries

  scope :dep_own_item, (lambda do |root_customer_id|
    joins("left join departments_regulation_items dri on dri.regulation_item_id = regulation_items.id")
      .where("coalesce(dri.department_id, :id) = :id", id: root_customer_id)
  end)

  scope :actuals, -> { where(is_actual: true) }

  scope :for_type, (lambda do |tender_type_id|
    joins(:tender_types).where(dictionaries: { ref_id: tender_type_id }).order(:num)
  end)

  validates :num, :tender_type_ids, presence: true
  validates :is_actual, inclusion: { in: [true, false] }

  accepts_nested_attributes_for :tender_types, allow_destroy: true
end

# frozen_string_literal: true

class InvestProject < ApplicationRecord
  include Constants
  has_paper_trail

  has_many :plan_specifications
  has_many :plan_lots, through: :plan_specifications

  belongs_to :department
  belongs_to :project_type, class_name: "Dictionary", foreign_key: "project_type_id"
  belongs_to :invest_project_name

  scope :by_year_and_dep, (lambda do |p_year, p_department|
    where(gkpz_year: p_year).where(department_id: p_department).order(:num)
  end)

  set_date_columns :date_install if oracle_adapter?
  money_fields :amount_financing

  validates :department_id, :gkpz_year, :project_type_id, :name, :num, :object_name, :date_install,
            :amount_financing, :amount_financing_money, presence: true
  validates :invest_project_name_id, presence: true, if: proc { |i| i.consumer_rao? }
  validates :gkpz_year, numericality: { only_integer: true }
  validates :power_elec_gen, :power_elec_net, :power_substation, :power_thermal_gen, :power_thermal_net,
            :amount_financing, numericality: { allow_nil: true }
  validates :num, :object_name, length: { maximum: 255 }
  validates :name, length: { maximum: 1500 }
  validate :power_presence

  delegate :name, to: :department, prefix: true
  delegate :name, to: :project_type, prefix: true
  delegate :name, :aqua_id, :fullname, to: :invest_project_name, prefix: true, allow_nil: true

  def consumer_rao?
    department_id == Departments::RAO
  end

  def participated_plan_lots
    PlanLot.actuals.where(guid: plan_lots.select('plan_lots.guid'))
  end

  def power_name
    powers = []
    powers << { value: power_elec_gen, unit: 'МВт' }
    powers << { value: power_thermal_gen, unit: 'Гкал/ч' }
    powers << { value: power_elec_net, unit: 'км' }
    powers << { value: power_thermal_net, unit: 'км' }
    powers << { value: power_substation, unit: 'МВА' }
    powers.select! { |p| p[:value] }
    powers.map! { |p| "#{p[:value]} #{p[:unit]}" }
    powers.join '; '
  end

  def fullname
    "#{num} #{name} / #{object_name}"
  end

  private

  def power_presence
    values = [
      power_elec_gen,
      power_elec_net,
      power_substation,
      power_thermal_gen,
      power_thermal_net
    ]
    if values.reject(&:blank?).size == 0
      errors[:base] << "Должны быть указаны параметры объекта, на который будут списаны затраты (мощность)."
    end
  end
end

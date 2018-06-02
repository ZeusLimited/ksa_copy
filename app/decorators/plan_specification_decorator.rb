class PlanSpecificationDecorator < Draper::Decorator
  delegate_all

  decorates_association :plan_lot

  def production_unit_names(delimiter = "\n")
    production_units.map(&:name).join(delimiter)
  end
end

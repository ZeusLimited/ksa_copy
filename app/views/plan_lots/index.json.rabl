collection @plan_lots

attributes *PlanLot.column_names

child(:plan_specifications) do
  attributes *PlanSpecification.column_names

  child :fias_plan_specifications do
    attributes *FiasPlanSpecification.column_names
  end
  child :plan_spec_amounts do
    attributes *PlanSpecAmount.column_names
  end
end

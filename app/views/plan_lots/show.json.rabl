object @plan_lot
attributes *PlanLot.column_names

child :protocol do
  attributes *Protocol.column_names
end

child :plan_lots_files do
  attributes :id, :note, :file_type_name, :tender_file_document
end

child :plan_annual_limits do
  attributes *PlanAnnualLimit.column_names
end
child :plan_lot_contractors do
  attributes :contractor_id
end
child :plan_specifications do
  attributes *PlanSpecification.column_names

  child :fias_plan_specifications do
    attributes *FiasPlanSpecification.column_names
  end
  child :plan_spec_amounts do
    attributes *PlanSpecAmount.column_names
  end
end

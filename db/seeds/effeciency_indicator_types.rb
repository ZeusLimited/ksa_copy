def indicator_types
  [
    { work_name: 'single_source',
      name: 'Доля закупок у единственного участника конкурентной закупки',
      weight: 0.5 },
    { work_name: 'competitive_efficiency',
      name: 'Достижение экономического эффекта по итогам конкурентных процедур',
      weight: 0.5 },
    { work_name: 'appeals',
      name: 'Доля процедур закупок, по которым жалобы на действия организатора закупки признаны обоснованными',
      weight: 0.5 },
    { work_name: 'terms_violated',
      name: 'Доля конкурентных закупок, по которым нарушены регламентные сроки начала проведения закупочных процедур',
      weight: 0.5 }
  ]
end

EffeciencyIndicatorType.delete_all

indicator_types.each do |indicator_type|
  puts indicator_type
  EffeciencyIndicatorType.create(indicator_type)
end

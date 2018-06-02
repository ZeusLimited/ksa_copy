object @tender
attributes *Tender.column_names
child :lots do
  attributes *Lot.column_names
  child :specifications do
    attributes *Specification.column_names
  end
end
child :link_tender_files do
  attributes *LinkTenderFile.column_names
end

collection @tenders
attributes *Tender.column_names

child(:lots) do
  attributes *Lot.column_names

  child(:specifications) { attributes *Specification.column_names }
end

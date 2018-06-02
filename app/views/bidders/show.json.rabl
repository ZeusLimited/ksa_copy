object @bidder

attributes :contractor_name_short, :contractor_id

child :bidder_files do
  attributes :id, :note, :tender_file_document
end

child :covers do
  attributes *Cover.column_names
end

collection @review_protocols

attributes *ReviewProtocol.column_names

child :review_lots do
  attributes *ReviewLot.column_names
end

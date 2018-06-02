collection @tender_files

attributes *TenderFile.column_names

node :filename do |tf|
  tf.document.file.filename
end

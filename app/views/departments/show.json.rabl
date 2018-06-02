object @department
attributes *Department.column_names
child :contact do
  attributes *Contact.column_names
  child legal_fias: :legal_fias do
    attributes *Fias.column_names
  end
  child postal_fias: :postal_fias do
    attributes *Fias.column_names
  end
end

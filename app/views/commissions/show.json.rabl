object @commission
attributes *Commission.column_names
attribute :name_r
child :commission_users do
  attributes *CommissionUser.column_names
end

collection @contractors, object_root: false
attributes *(Contractor.column_names - ["guid"])
attribute :name_long
attribute name_long: :label
attribute :guid_hex

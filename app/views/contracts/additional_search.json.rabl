collection @contracts, root: "contracts", object_root: false
attributes :id, :num, :lot_name, :gkpz_year
node(:confirm_date) { |c| c.confirm_date.strftime('%d.%m.%Y') }

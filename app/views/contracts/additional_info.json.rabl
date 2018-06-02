object false
node(:parent_id) { @contract.id }
node(:num) { @contract.num }
node(:confirm_date) { @contract.confirm_date.strftime('%d.%m.%Y') }
node(:lot_name) { @contract.lot_name }
node(:gkpz_year) { @contract.gkpz_year }

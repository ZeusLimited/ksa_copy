object false
node(:okdp_id) { @okdp.try(:id) }
node(:okdp_name) { @okdp.try(:fullname) }
node(:okved_id) { @okved.try(:id) }
node(:okved_name) { @okved.try(:fullname) }

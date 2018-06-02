# frozen_string_literal: true

object false
node(:id) { @plan_lot&.guid_hex }
node(:num_tender) { @plan_lot&.num_tender }
node(:num_lot) { @plan_lot&.num_lot }
node(:lot_name) { @plan_lot&.lot_name }
node(:gkpz_year) { @plan_lot&.gkpz_year }

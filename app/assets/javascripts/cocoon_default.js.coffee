check_to_hide_remove_link = (selector, min_items) ->
  if $("#{selector}.nested-fields:visible").length <= min_items
    $("#{selector}.nested-fields a.remove_fields").hide()
  else
    $("#{selector}.nested-fields a.remove_fields").show()

min_defaults = ->
  check_to_hide_remove_link('.bidders', 1)
  check_to_hide_remove_link('.offers', 1)

$(document).on 'cocoon:after-insert', 'form', (e, insertedItem) ->
  load_defaults(insertedItem)
  toggle_contract_info(insertedItem)
  coloring()
  min_defaults()

$(document).on 'cocoon:after-remove', 'form', (e, removedItem) ->
  min_defaults()

min_defaults()

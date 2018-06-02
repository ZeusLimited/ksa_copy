document.addEventListener "turbolinks:load", ->
  $('#sub_contractor_contractor_name_long').autocomplete
    source: '/contractors/search'
    select: (event, ui) ->
      $('#sub_contractor_contractor_id').val(ui.item.id)

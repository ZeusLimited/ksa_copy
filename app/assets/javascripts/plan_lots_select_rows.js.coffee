select_list_path = '/user_plan_lots/select_list'
unselect_list_path = '/user_plan_lots/unselect_list'
unselect_all_path = '/user_plan_lots/unselect_all'

ajax_request = (url, data) ->
  $.ajax
    url: url,
    type: "POST",
    dataType: "script",
    data: data

$(document).on 'click', '.remove-all-from-selected', (event) ->
  if (confirm("Вы действительно хотите убрать все лоты из выделенных?"))
    $('#selected_all').prop('checked', false)
    $("#lots tbody tr input:checkbox").prop('checked', false)
    ajax_request(unselect_all_path)
  event.preventDefault()

$(document).on 'click', '.remove-from-selected', (event) ->
  lot_id = $(this).closest('tr').data('plan-lot-id')
  $("#lots tbody tr[data-plan-lot-id=#{lot_id}] input:checkbox").prop('checked', false)
  ajax_request(unselect_list_path, { plan_lot_ids: [lot_id] })
  event.preventDefault()

$(document).on 'change', '#lots tbody input:checkbox', (event) ->
  lot_id = $(this).val()

  url = if $(this).is(':checked') then select_list_path else unselect_list_path
  ajax_request(url, { plan_lot_ids: [lot_id] })

$(document).on 'change', '#selected_all', (event) ->
  if ($('#lots tbody tr').length)
    lot_ids = $('#lots tbody tr').map -> $(this).data('plan-lot-id')

    $("#lots tbody tr input:checkbox").prop('checked', $(this).is(':checked'))

    url = if $(this).is(':checked') then select_list_path else unselect_list_path
    ajax_request(url, { plan_lot_ids: lot_ids.get() })

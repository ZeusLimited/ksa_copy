$(document).on 'change', '#subscribes tbody input:checkbox', (event) ->
  subscribe_id = $(this).val()

  url = if $(this).is(':checked') then $(this).data('push-url') else $(this).data('pop-url')
  $.ajax
    url: url,
    type: "POST",
    dataType: "script",
    data: { subscribe_ids: [subscribe_id] }

$(document).on 'change', '#selected_all_subscribes', (event) ->
  if ($('#subscribes tbody tr').length)
    subscribe_ids = $('#subscribes tbody tr').map -> $(this).data('subscribe-id')

    $("#subscribes tbody tr input:checkbox").prop('checked', $(this).is(':checked'))

    url = if $(this).is(':checked') then $(this).data('push-url') else $(this).data('pop-url')
    $.ajax
      url: url,
      type: "POST",
      dataType: "script",
      data: { subscribe_ids: subscribe_ids.get() }

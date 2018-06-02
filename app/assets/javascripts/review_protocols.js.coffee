$(document).on 'change', '.rebid_switch', (event) ->
  disabled = ($(this).val() == "false")
  $(this).closest('td').nextAll().each ->
    $(this).find('input').prop('disabled', disabled)

$(document).on 'click', '.update_confirm_date', (event) ->
  error_container = $('#change_confirm_date').find('.error-container')
  $.ajax
    type: "PATCH",
    url: $(this).data('url'),
    data: { confirm_date: $(this).closest('#change_confirm_date').find('.confirm_date').val() }
    success: (data) ->
      obj = $(document).find('span.protocol-title')
      obj.html(data['title'])
      obj.effect 'highlight', null, 2000
      error_container.html('')
      $('#change_confirm_date').modal('hide')
    error: (data) ->
      error_container.html(data.responseText)
  event.preventDefault()

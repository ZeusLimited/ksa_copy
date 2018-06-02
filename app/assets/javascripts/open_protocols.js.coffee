$(document).on 'click', 'form .remove_present_bidder_fields', (event) ->
  $(this).closest('fieldset').children('input:hidden').val('1')
  $(this).closest('fieldset').hide 'blind'
  event.preventDefault()

$(document).on 'change', '#open_protocol_commission_id', (event) ->
  params =
    commission_id: $(this).val()
    open_protocol_id: $(this).data('open-protocol-id')
  $('#open_protocol_present_members').load $(this).data('url'), params, ->
    name = $('#open_protocol_present_members').find('tr.clerk').find('label.name').html()
    id = $('#open_protocol_present_members').find('tr.clerk').children('input:hidden').val()
    $('form').find('.clerk_info').children('p').html(if name then name else '')
    $('form').find('.clerk_info').children('input:hidden').val(if id then id else '')


document.addEventListener "turbolinks:load", ->

  $('#open_protocol_commission_id').change()

$(document).on 'change', '#rebid_protocol_commission_id', (event) ->
  params =
    commission_id: $(this).val()
    rebid_protocol_id: $(this).data('rebid-protocol-id')
  $('#rebid_protocol_present_members').load $(this).data('url'), params, ->
    name = $('#rebid_protocol_present_members').find('tr.clerk').find('label.name').html()
    id = $('#rebid_protocol_present_members').find('tr.clerk').children('input:hidden').val()
    $('form').find('.clerk_info').children('p').html(if name then name else '')
    $('form').find('.clerk_info').children('input:hidden').val(if id then id else '')

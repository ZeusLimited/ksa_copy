$(document).on 'click', '.tender-file-delete', (event) ->
  if (confirm("Вы уверены?"))
    $(this).closest('tr').remove()
  event.preventDefault()

$(document).on 'hidden', '#assign_files', (event) ->
  $('#hidden_files').empty()

  $('#tender_files tr').each ->
    tender_file_id = $(this).data('tender-file-id')
    file_type_id = $(this).find('[name=file_type_id]').val()
    note = $(this).find('[name=note]').val()

    time = new Date().getTime()
    name_start = "plan_lot[plan_lots_files_attributes][#{time}]"

    $('#hidden_files').append($('<input />').attr('type', 'hidden').attr('name', name_start + '[tender_file_id]').val(tender_file_id))
    $('#hidden_files').append($('<input />').attr('type', 'hidden').attr('name', name_start + '[file_type_id]').val(file_type_id))
    $('#hidden_files').append($('<input />').attr('type', 'hidden').attr('name', name_start + '[note]').val(note))

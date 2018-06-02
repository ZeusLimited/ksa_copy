$(document).on 'click', '.positive', (event) ->
  fieldset = $(this).closest('fieldset')
  params =
    draft_opinion:
      expert_id: $('#expert_id').val()
      criterion_id: fieldset.children('#criterion_id').val()
      description: fieldset.find('textarea[name=description]').val()
      vote: true
  $.post 'update_draft', params, (data) ->
    fieldset.removeClass('negative_opinion').addClass('positive_opinion')

$(document).on 'click', '.negative', (event) ->
  fieldset = $(this).closest('fieldset')
  txtarea = fieldset.find('textarea[name=description]')
  if (confirm("Вы хотите заменить текст в примечаниях на стандартный?"))
    txtarea.val("указанное несоответствие требованиям закупочной документации является не достаточным основанием для отклонения основного предложения")
  unless (txtarea.val() == '')
    params =
      draft_opinion:
        expert_id: $('#expert_id').val()
        criterion_id: fieldset.children('#criterion_id').val()
        description: txtarea.val()
        vote: false
    $.post 'update_draft', params, (data) ->
      fieldset.removeClass('positive_opinion').addClass('negative_opinion')
  else
    alert('Не заполнены пояснения')

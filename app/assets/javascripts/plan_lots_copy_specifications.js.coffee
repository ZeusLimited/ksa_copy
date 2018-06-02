additional_search_path = "/plan_lots/search_edit_list.json"

@validateCopyPlanSpecForm = () ->
  if $('#preselection_id').val() == ""
    alert 'Необходимо выбрать лот перед продолжением!'
    return false
  else
    return true

document.addEventListener "turbolinks:load", ->
  $('#preselection_id').select2
    placeholder: "Выберите закупку"
    minimumInputLength: 1
    allowClear: true
    ajax:
      url: additional_search_path
      dataType: 'json'
      data: (term, page) ->
        q: term
      results: (data, page) -> { results: data.plan_lots }
    formatResult: planlotFormatResult
    formatSelection: planlotFormatSelection

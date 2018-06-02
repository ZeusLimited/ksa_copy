formatResult = (obj, container, query) ->
  name = obj.name.replace(new RegExp(query.term, "gi"), "<strong>$&</strong>")
  "#{name} (#{obj.aqua_id})"

formatSelection = (obj) ->
  ipn_hidden.data('name', obj.name)
  ipn_hidden.data('aqua-id', obj.aqua_id)
  "#{obj.name} (#{obj.aqua_id})"

ipn_hidden = ''

document.addEventListener "turbolinks:load", ->
  ipn_hidden = $('#invest_project_invest_project_name_id')

  ipn_hidden.select2
    placeholder: "Выберите проект из системы АКВА"
    allowClear: true
    minimumInputLength: 1
    ajax:
      url: ipn_hidden.data('url')
      dataType: 'json'
      data: (term, page) -> { q: term, dep_id: $('#invest_project_department_id').val() }
      results: (data, page) -> { results: data }
    initSelection: (element, callback) ->
      add_id = $(element).val()
      if add_id isnt ""
        data = { name: ipn_hidden.data('name'), aqua_id: ipn_hidden.data('aqua-id') }
        callback(data)
    formatResult: formatResult
    formatSelection: formatSelection

  ipn_hidden.on 'change', (event) ->
    if $(this).val() isnt ""
      if (confirm("Вы хотите скопировать наименование проекта?"))
        $('#invest_project_name').val($(this).data('name'))

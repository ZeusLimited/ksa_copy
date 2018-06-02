monitor_service_Format = (c) ->
  c.title

document.addEventListener "turbolinks:load", ->
  $('.monitor_service').select2
    placeholder: "Выберите курирующее подразделение"
    minimumInputLength: 3
    allowClear: true
    ajax:
      url: '/departments/nodes_for_filter'
      dataType: 'json'
      data: (term, page) ->
        filter: term
      results: (data, page) -> { results: data }
    initSelection: (element, callback) ->
      id = $(element).val()
      if id isnt ""
        $.ajax
          url: '/department/show'
          data: { id: id }
          dataType: 'json'
        .done (data) -> callback(data['department'])
    formatResult: monitor_service_Format
    formatSelection: monitor_service_Format

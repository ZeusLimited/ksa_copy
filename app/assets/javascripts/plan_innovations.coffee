# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
okvedFormat = (c) ->
  [c.code, c.name].join(' - ')

document.addEventListener "turbolinks:load", ->
  $('.okdp').select2
    placeholder: "Выберите ОКДП"
    multiple: $('.okdp').data('multiple')
    minimumInputLength: 2
    allowClear: true
    ajax:
      url: '/okdp/nodes_for_filter'
      dataType: 'json'
      data: (term, page) ->
        filter: term
        type: 'OKPD2'
      results: (data, page) -> { results: data }
    initSelection: (element, callback) ->
      id = $(element).val()
      if id isnt ""
        $.ajax
          url: '/okdp/index'
          data: { ids: id }
          dataType: 'json'
        .done (data) -> callback(if element.data('multiple') then data else data[0])
    formatResult: okvedFormat
    formatSelection: okvedFormat

  $('.okved').select2
    placeholder: "Выберите ОКВЭД"
    multiple: $('.okved').data('multiple')
    minimumInputLength: 2
    allowClear: true
    ajax:
      url: '/okveds/nodes_for_filter'
      dataType: 'json'
      data: (term, page) ->
        filter: term
        type: 'OKVED2'
      results: (data, page) -> { results: data }
    initSelection: (element, callback) ->
      id = $(element).val()
      if id isnt ""
        $.ajax
          url: '/okveds/index'
          data: { ids: id }
          dataType: 'json'
        .done (data) -> callback(if element.data('multiple') then data else data[0])
    formatResult: okvedFormat
    formatSelection: okvedFormat

@add_select_all_clear = ->
  $('.select-all-clear').each ->
    html = $(this).html()
    unless html.match /Выделить все/
      html += ' <a data-toggle="tooltip" title="Выделить все"><i class="icon-list select-all"></i>'
      html += ' <a data-toggle="tooltip" title="Очистить"><i class="icon-remove select-clear"></i>'
      $(this).html html

@add_select_all_clear_roots = ->
  $('.select-all-clear-roots').each ->
    html = $(this).html()
    unless html.match /Выделить все/
      html += ' <a data-toggle="tooltip" title="Выделить все корневые"><i class="icon-list select-all-roots"></i>'
      html += ' <a data-toggle="tooltip" title="Очистить"><i class="icon-remove select-clear"></i>'
      $(this).html html

$(document).on 'click', '.select-all', (event) ->
  element = $(this).closest('.control-group').find('select')
  selected = []
  element.find("option").each (i, e) ->
    selected[selected.length] = $(e).attr("value")
  element.select2 "val", selected

$(document).on 'click', '.select-clear', (event) ->
  element = $(this).closest('.control-group').find('select')
  element.select2 "val", ""

$(document).on 'click', '.select-all-roots', (event) ->
  element = $(this).closest('.control-group').find('select')
  selected = []
  element.find("option").each (i, e) ->
    selected[selected.length] = $(e).attr("value") if /^ /.test($(e).text())
  element.select2 "val", selected

document.addEventListener "turbolinks:load", ->
  add_select_all_clear()
  add_select_all_clear_roots()

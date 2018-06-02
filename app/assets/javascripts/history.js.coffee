document.addEventListener "turbolinks:load", ->
  $('table.history tbody tr').each (index) ->
    vals = $('td', this).map -> $(this).text()
    uniq_vals = vals.get().filter (e, i, arr) -> arr.lastIndexOf(e) == i # get uniq values
    $(this).addClass('changed') if uniq_vals.length > 1

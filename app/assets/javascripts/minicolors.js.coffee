document.addEventListener "turbolinks:load", ->
  $('#dictionary_color').minicolors
    theme: 'bootstrap'
    change: (hex, opacity) ->
      $('#dictionary_stylename_html').val("background-color: #{hex};")

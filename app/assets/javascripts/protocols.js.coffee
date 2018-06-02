document.addEventListener "turbolinks:load", ->
  $("#form_merge_protocols").submit ->
    if $('input.pids:checked').length < 2
      alert 'Для объединения необходимо выбрать минимум 2 протокола.'
      false

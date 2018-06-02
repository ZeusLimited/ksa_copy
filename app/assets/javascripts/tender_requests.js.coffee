# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

document.addEventListener "turbolinks:load", ->

  $("#tender_request_user_name").autocomplete
    source: "/user/search"
    select: (event, ui) ->
      $("#tender_request_user_id").val(ui.item.id)

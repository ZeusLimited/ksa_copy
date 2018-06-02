contactsFormatResult = (c) ->
  # "<h4 class=\"text-success\">#{c.label}</h4>"
  "#{c.label}"

contactsFormatSelection = (c) ->
  "#{if c[0] then c[0].label else c.label}"

contact_search_path = "/user/search.json"
contact_info_path = "/user/info.json"

@search_for_contacts = ->
  $('.autocomplete-contacts').select2
    placeholder: "Выберите пользователя"
    minimumInputLength: 1
    multiple: false
    allowClear: false
    ajax:
      url: contact_search_path
      dataType: 'json'
      data: (term, page) ->
        term: term
      results: (data, page) -> { results: data }
    initSelection: (element, callback) ->
      id = $(element).val()
      if id isnt ""
        $.ajax
          url: contact_info_path
          data: { id: id }
          dataType: 'json'
        .done (data) -> callback(data)
    formatResult: contactsFormatResult
    formatSelection: contactsFormatSelection

document.addEventListener "turbolinks:load", ->
  search_for_contacts()

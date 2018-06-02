contractorFormatResult = (c) ->
  # "<h4 class=\"text-success\">#{c.label}</h4>"
  "#{c.label}"

contractorFormatSelection = (c) ->
  "#{c.label}"

contractor_search_path = "/contractors/search_reports.json"
contractor_info_path = "/contractors/info.json"

@multi_for_contractors = ->
  $('.autocomplete-contractors-select').select2
    placeholder: "Все"
    minimumInputLength: 1
    multiple: true
    allowClear: true
    ajax:
      url: contractor_search_path
      dataType: 'json'
      data: (term, page) ->
        term: term
      results: (data, page) -> { results: data }
    initSelection: (element, callback) ->
      id = $(element).val()
      if id isnt ""
        $.ajax
          url: contractor_info_path
          data: { id: id }
          dataType: 'json'
        .done (data) -> callback(data)
    formatResult: contractorFormatResult
    formatSelection: contractorFormatSelection

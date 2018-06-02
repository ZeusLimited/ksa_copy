contractFormatResult = (c) ->
  markup = "<h4 class=\"text-success\">№#{c.num} от #{c.confirm_date} (ГКПЗ - #{c.gkpz_year})</h4>"
  markup += "<div>#{c.lot_name}</div>";

contractFormatSelection = (c) ->
  "(ГКПЗ - #{c.gkpz_year}) №#{c.num} от #{c.confirm_date} #{c.lot_name}"

document.addEventListener "turbolinks:load", ->

  $('#contract_parent_id, .additional-contract-search').select2
    placeholder: "Выберите основной договор"
    minimumInputLength: 1
    allowClear: true
    ajax:
      url: $('#contract_parent_id').data('url-search')
      dataType: 'json'
      data: (term, page) ->
        q: term
      results: (data, page) -> { results: data.contracts }
    initSelection: (element, callback) ->
      add_id = $(element).val()
      if add_id isnt ""
        $.ajax
          url: $('#contract_parent_id').data('url-info')
          data: { id: add_id }
          dataType: 'json'
        .done (data) -> callback(data)
    formatResult: contractFormatResult
    formatSelection: contractFormatSelection

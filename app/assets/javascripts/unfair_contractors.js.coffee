lotFormatResult = (lots) ->
  markup = "<h4 class=\"text-success\">#{lots.tender_num} - Год ГКПЗ: #{lots.gkpz_year}</h4>"
  markup += "<div>#{lots.fullname}</div>";

lotFormatSelection = (lots) ->
  "#{lots.tender_num} #{lots.fullname}"

document.addEventListener "turbolinks:load", ->

  $('#unfair_contractor_lot_ids').select2
    placeholder: "Выберите основную закупку"
    multiple: true
    minimumInputLength: 4
    allowClear: true
    ajax:
      url: $('#unfair_contractor_lot_ids').data('url-lots')
      dataType: 'json'
      data: (term, page) ->
        name: term
        contractor_id: $("#unfair_contractor_contractor_id").val()
      results: (data, page) -> { results: data.lots }
    initSelection: (element, callback) ->
      add_lot = $(element).val()
      if add_lot isnt ""
        $.ajax
          url: $('#unfair_contractor_lot_ids').data('url-lots-info')
          data: { lot_id: add_lot }
          dataType: 'json'
        .done (data) -> callback(data.lots)
    formatResult: lotFormatResult
    formatSelection: lotFormatSelection

  multi_for_contractors()

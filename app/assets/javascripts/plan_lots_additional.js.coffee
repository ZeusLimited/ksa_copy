@planlotFormatResult = (pl) ->
  markup = "<h4 class=\"text-success\">#{pl.num_tender}.#{pl.num_lot} (ГКПЗ - #{pl.gkpz_year})</h4>"
  markup += "<div>#{pl.lot_name}</div>";

@planlotFormatSelection = (pl) ->
  if pl.id
    "(ГКПЗ - #{pl.gkpz_year}) #{pl.num_tender}.#{pl.num_lot} #{pl.lot_name}"
  else
    "Лот был удален"

additional_search_path = "/plan_lots/additional_search.json"
additional_info_path = "/plan_lots/additional_info.json"

change_is_additional = ->
  if $('#plan_lot_is_additional').prop('checked')
    $('.additional').show()
  else
    $('.additional').hide()

document.addEventListener "turbolinks:load", ->
  change_is_additional()
  $('#plan_lot_is_additional').change change_is_additional

  $('#plan_lot_additional_to_hex').select2
    placeholder: "Выберите основную закупку"
    minimumInputLength: 1
    allowClear: true
    ajax:
      url: additional_search_path
      dataType: 'json'
      data: (term, page) ->
        q: term
        cust_id: $('select.customers').first().val()
      results: (data, page) -> { results: data.plan_lots }
    initSelection: (element, callback) ->
      add_guid = $(element).val()
      if add_guid isnt ""
        $.ajax
          url: additional_info_path
          data: { guid: add_guid }
          dataType: 'json'
        .done (data) -> callback(data)
    formatResult: planlotFormatResult
    formatSelection: planlotFormatSelection

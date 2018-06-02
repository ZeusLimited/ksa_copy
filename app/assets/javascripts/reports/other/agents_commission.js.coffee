additional_search_path = "/plan_lots/search_all.json"

@agents_commissions_lot_num_select2 = ->
  $('.lot-num-select').select2
    placeholder: "Выберите закупку"
    minimumInputLength: 1
    allowClear: true
    multiple: true
    ajax:
      url: additional_search_path
      dataType: 'json'
      data: (term, page) ->
        q: term
        cust_id: $('select.customers_for_lots').first().val()
        gkpz_years: $('select.years_for_lots').val()
      results: (data, page) -> { results: data.plan_lots }
    formatResult: planlotFormatResult
    formatSelection: planlotFormatSelection
